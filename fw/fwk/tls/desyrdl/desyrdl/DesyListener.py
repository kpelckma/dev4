#!/usr/bin/env python
# --------------------------------------------------------------------------- #
#           ____  _____________  __                                           #
#          / __ \/ ____/ ___/\ \/ /                 _   _   _                 #
#         / / / / __/  \__ \  \  /                 / \ / \ / \                #
#        / /_/ / /___ ___/ /  / /               = ( M | S | K )=              #
#       /_____/_____//____/  /_/                   \_/ \_/ \_/                #
#                                                                             #
# --------------------------------------------------------------------------- #
# @copyright Copyright 2021-2022 DESY
# SPDX-License-Identifier: Apache-2.0
# --------------------------------------------------------------------------- #
# @date 2021-04-07/2023-02-15
# @author Michael Buechler <michael.buechler@desy.de>
# @author Lukasz Butkowski <lukasz.butkowski@desy.de>
# --------------------------------------------------------------------------- #
"""DesyRdl main class.

Create context dictionaries for each address space node.
Context dictionaries are used by the template engine.
"""

import re
from math import ceil, log2
from pathlib import Path
from systemrdl import AddressableNode, RDLListener
from systemrdl.messages import MessageHandler, MessagePrinter, Severity
from systemrdl.node import (AddrmapNode, FieldNode,  # AddressableNode,
                            MemNode, RegfileNode, RegNode, RootNode)
# import desyrdl
import jinja2

from desyrdl.rdlformatcode import desyrdlmarkup

# class convert dict to attributes of object
class AttributeDict(dict):
    __getattr__ = dict.get
    __setattr__ = dict.__setitem__
    __delattr__ = dict.__delitem__

# Define a listener that will print out the register model hierarchy
class DesyListener(RDLListener):

    def __init__(self):
        # def __init__(self, formatter, templates, out_dir, separator="."):
        self.separator = "."

        # global context
        self.top_items = list()
        self.top_regs = list()
        self.top_mems = list()
        self.top_exts = list()
        self.top_regf = list()

        self.top_context = dict()
        self.top_context['addrmaps'] = list()
        self.top_context['separator'] = self.separator
        self.top_context['interface_adapters'] = list()
        # local address map contect only
        # self.items = list()
        # self.regs = list()
        # self.mems = list()
        # self.exts = list()
        # self.regf = list()
        self.context = dict()

        self.md = desyrdlmarkup() # parse description with markup lanugage, disable Mardown
        message_printer = MessagePrinter()
        self.msg = MessageHandler(message_printer)

    # =========================================================================
    def exit_Addrmap(self, node : AddrmapNode):
        self.context.clear();
        self.context['insts'] = list()
        self.context['reg_insts'] = list()
        self.context['mem_insts'] = list()
        self.context['ext_insts'] = list()
        self.context['rgf_insts'] = list()
        self.context['reg_types'] = list()
        self.context['mem_types'] = list()
        self.context['ext_types'] = list()
        self.context['rgf_types'] = list()
        self.context['reg_type_names'] = list()
        self.context['mem_type_names'] = list()
        self.context['ext_type_names'] = list()
        self.context['rgf_type_names'] = list()

        self.context['regs']  = list()
        self.context['mems']  = list()
        self.context['exts']  = list()
        self.context['regf']  = list()
        self.context['n_regs'] = 0
        self.context['n_mems'] = 0
        self.context['n_exts'] = 0
        self.context['n_regf'] = 0

        self.context['interface_adapters'] = list()
        #------------------------------------------
        self.context['node'] = node
        self.context['type_name'] = node.type_name
        self.context['inst_name'] = node.inst_name
        self.context['type_name_org'] = node.inst.original_def.type_name if node.inst.original_def is not None else node.type_name

        self.context['interface'] = node.get_property('desyrdl_interface')
        self.context['access_channel'] = self.get_access_channel(node)
        self.context['addrwidth']=ceil(log2(node.size))

        self.context['desc'] = node.get_property("desc")
        self.context['desc_html'] = node.get_html_desc(self.md)

        path_segments = node.get_path_segments(array_suffix=f'{self.separator}{{index:d}}', empty_array_suffix='')
        self.context['path_segments'] = path_segments
        self.context['path'] = self.separator.join(path_segments)
        self.context['path_notop'] = self.separator.join(path_segments[1:])
        self.context['path_addrmap_name'] = path_segments[-1]

        self.set_item_dimmentions(node, self.context)
        #------------------------------------------
        self.gen_items(node, self.context)
        self.context['regs'] = self.unroll_inst('reg_insts',self.context)
        self.context['mems'] = self.unroll_inst('mem_insts',self.context)
        self.context['regf'] = self.unroll_inst('rgf_insts',self.context)
        self.context['exts'] = self.unroll_inst('ext_insts',self.context)

        #------------------------------------------
        self.context['n_reg_insts'] = len(self.context['reg_insts'])
        self.context['n_mem_insts'] = len(self.context['mem_insts'])
        self.context['n_ext_insts'] = len(self.context['ext_insts'])
        self.context['n_rgf_insts'] = len(self.context['rgf_insts'])

        self.context['n_regs'] = len(self.context['regs'])
        self.context['n_mems'] = len(self.context['mems'])
        self.context['n_exts'] = len(self.context['exts'])
        self.context['n_regf'] = len(self.context['regf'])

        self.context['n_regf_regs'] = 0
        for rf in self.context['regf']:
            self.context['n_regf_regs'] += len(rf['regs'])

        #------------------------------------------
        self.top_context['addrmaps'].append(self.context.copy())
        self.top_context['access_channel'] = self.context['access_channel']
        self.top_context['interface_adapters'] = self.top_context['interface_adapters'] + self.context['interface_adapters'].copy()

    # =========================================================================
    def unroll_inst(self, insts, context):
        # unroll all registers in addrmap + regfilex and recalculate index for insts
        index = 0
        idx_insts = list ()
        instsc = list ()
        for inst in context[insts]:
            inst['idx'] = index
            idx_insts.append(inst)
            for idx in range(inst['elements']):
                instc = inst.copy()
                instc['idx'] = index
                instc['address_offset'] = inst['address_offset'] + inst['array_stride'] * idx
                instc['absolute_address'] = inst['absolute_address'] + inst['array_stride'] * idx
                if inst['node'].is_array:
                    instc['address_offset_high'] = instc['address_offset'] + inst['array_stride']-1
                    instc['absolute_address_high'] = instc['absolute_address'] + inst['array_stride']-1
                instsc.append(instc)
                index += 1

        context[insts] = idx_insts
        return instsc

    # =========================================================================
    def gen_items (self, node, context):

        for item in node.children(unroll=False):
            itemContext = dict()
            # common to all items values
            itemContext['node'] = item
            itemContext['type_name'] = item.type_name
            itemContext['inst_name'] = item.inst_name
            itemContext['type_name_org'] = item.inst.original_def.type_name if item.inst.original_def is not None else item.type_name
            itemContext['access_channel'] = self.get_access_channel(item)
            itemContext['address_offset'] = item.raw_address_offset
            itemContext['address_offset_high'] = item.raw_address_offset + int(item.total_size)-1
            itemContext['absolute_address'] = item.raw_absolute_address
            itemContext['absolute_address_high'] = item.raw_absolute_address + int(item.total_size)-1
            itemContext['array_stride'] = item.array_stride if item.array_stride is not None else 0
            itemContext['total_size'] = item.total_size
            itemContext['total_words'] = int(item.total_size / 4)

            # default
            itemContext["width"] = 32
            itemContext["dtype"] = "uint"
            itemContext["signed"] = 0
            itemContext["fixedpoint"] = 0
            itemContext["rw"] = "RW"

            itemContext['desc'] = item.get_property("desc")
            itemContext['desc_html'] = item.get_html_desc(self.md)

            self.set_item_dimmentions(item, itemContext)

            # add all non-native explicitly set properties
            for prop in item.list_properties(list_all=True):
                itemContext[prop] = item.get_property(prop)

            # item specyfic context
            if isinstance(item, RegNode):
                itemContext['node_type'] = "REG"
                self.gen_regitem(item, context=itemContext)
                context['reg_insts'].append(itemContext)
                if item.type_name not in context['reg_type_names']:
                    context['reg_type_names'].append(item.type_name)
                    context['reg_types'].append(itemContext)

            elif isinstance(item, MemNode):
                itemContext['node_type'] =  "MEM"
                self.gen_memitem(item, context=itemContext)
                context['mem_insts'].append(itemContext)
                if item.type_name not in context['mem_type_names']:
                    context['mem_type_names'].append(item.type_name)
                    context['mem_types'].append(itemContext)

            elif isinstance(item, AddrmapNode):
                itemContext['node_type'] = "ADDRMAP"
                self.gen_extitem(item, context=itemContext)
                context['ext_insts'].append(itemContext)
                if itemContext['interface'] != context['interface'] and \
                    context['interface'] is not None and \
                    itemContext['interface'] is not None:
                    adapter_name = context['interface'].lower() + "_to_" + itemContext['interface'].lower()
                    if adapter_name not in context['interface_adapters']:
                        context['interface_adapters'].append(adapter_name)
                if item.type_name not in context['ext_type_names']:
                    context['ext_type_names'].append(item.type_name)
                    context['ext_types'].append(itemContext)

            elif isinstance(item, RegfileNode):
                 itemContext['node_type'] = "REGFILE"
                 self.gen_rfitem(item, context=itemContext)
                 context['rgf_insts'].append(itemContext)
                 if item.type_name not in context['rgf_type_names']:
                    context['rgf_type_names'].append(item.type_name)
                    context['rgf_types'].append(itemContext)

            # append item contect to items list
            context['insts'].append(AttributeDict(itemContext))

    # =========================================================================
    def set_item_dimmentions(self, item: AddressableNode, itemContext: dict):
        #-------------------------------------
        dim_n = 1
        dim_m = 1
        dim = 1

        if item.is_array:
            if len(item.array_dimensions) == 2:
                dim_n = item.array_dimensions[0]
                dim_m = item.array_dimensions[1]
                dim = 3
            elif len(item.array_dimensions) == 1:
                dim_n = 1
                dim_m = item.array_dimensions[0]
                dim = 2

        itemContext["elements"] = dim_n * dim_m
        itemContext["dim_n"] = dim_n
        itemContext["dim_m"] = dim_m
        itemContext["dim"] = dim


    # =========================================================================
    def gen_extitem (self, extx: AddrmapNode, context):
        context['interface'] = extx.get_property('desyrdl_interface')
        context['access_channel'] = self.get_access_channel(extx)
        context['addrwidth']=ceil(log2(extx.size))


    # =========================================================================
    def gen_regitem (self, regx: RegNode, context):
        #-------------------------------------
        totalwidth = 0
        n_fields = 0
        reset = 0
        fields = list()
        for field in regx.fields():
            totalwidth += field.get_property("fieldwidth")
            n_fields += 1
            field_reset = 0
            fieldContext = dict()
            mask = self.bitmask(field.get_property("fieldwidth"))
            mask = mask << field.low
            fieldContext['mask'] = mask
            fieldContext['mask_hex'] = hex(mask)
            if(field.get_property("reset")):
                field_reset = field.get_property("reset")
                reset |= (field_reset << field.low) & mask
            fieldContext['node'] = field
            self.gen_fielditem(field, fieldContext)
            fieldC = AttributeDict(fieldContext)
            fields.append(fieldC)
            #print(fieldC.mask)

        context["width"] = totalwidth
        context["dtype"] = regx.get_property("desyrdl_data_type") or "uint"
        context["signed"] = self.get_data_type_sign(regx)
        context["fixedpoint"] = self.get_data_type_fixed(regx)
        if not regx.has_sw_writable and regx.has_sw_readable:
            context["rw"] = "RO"
        elif regx.has_sw_writable and not regx.has_sw_readable:
            context["rw"] = "WO"
        else:
            context["rw"] = "RW"
        context["reset"] = reset
        context["reset_hex"] = hex(reset)
        context["fields"] = fields
        context["fields_count"] = len(fields)

    # =========================================================================
    def gen_fielditem (self, fldx: FieldNode, context):
        for prop in fldx.list_properties(list_all=True):
            context[prop] = fldx.get_property(prop)
        context['node']  = fldx
        context['type_name'] = fldx.type_name
        context['inst_name'] = fldx.inst_name
        context["width"] = fldx.get_property("fieldwidth")
        context["sw"] = fldx.get_property("sw").name
        context["hw"] = fldx.get_property("hw").name
        if not fldx.is_sw_writable and fldx.is_sw_readable:
            context["rw"] = "RO"
        elif fldx.is_sw_writable and not fldx.is_sw_readable:
            context["rw"] = "WO"
        else:
            context["rw"] = "RW"
        context["const"] = 1 if fldx.get_property("hw").name == "na" or fldx.get_property("hw").name == "r" else 0
        context["reset"] = 0 if fldx.get_property("reset") is None else self.to_int32(fldx.get_property("reset"))
        context["reset_hex"] = hex(context["reset"])
        context["low"] = fldx.low
        context["high"] = fldx.high
        context["decrwidth"] = fldx.get_property("decrwidth") if fldx.get_property("decrwidth") is not None else 0
        context["incrwidth"] = fldx.get_property("incrwidth") if fldx.get_property("incrwidth") is not None else 0
        context["decrvalue"] = fldx.get_property("decrvalue") if fldx.get_property("decrvalue") is not None else 0
        context["incrvalue"] = fldx.get_property("incrvalue") if fldx.get_property("incrvalue") is not None else 0
        context["dtype"] = fldx.get_property("desyrdl_data_type") or "uint"
        context["signed"] = self.get_data_type_sign(fldx)
        context["fixedpoint"] = self.get_data_type_fixed(fldx)
        context["desc"] = fldx.get_property("desc") or ""
        context["desc_html"] = fldx.get_html_desc(self.md) or ""
        # check if we flag is set
        if fldx.is_hw_writable and fldx.is_sw_writable and not fldx.get_property("we") and fldx.is_virtual is False:
            self.msg.warning(
                    f"missing 'we' flag. 'sw = {fldx.get_property('sw').name}' " + \
                    f"and 'hw = {fldx.get_property('hw').name}' both can write to the register filed. " + \
                    f"'sw' will be always overwritten.\nRegister: {fldx.parent.inst_name}",
                    fldx.inst.property_src_ref.get('we', fldx.inst.def_src_ref) )
            # exit(1)

    # =========================================================================
    def gen_memitem (self, memx: MemNode, context):
        context["entries"] = memx.get_property("mementries")
        context["addresses"] = memx.get_property("mementries") * 4
        context["datawidth"] = memx.get_property("memwidth")
        context["addrwidth"] = ceil(log2(memx.get_property("mementries") * 4))
        context["width"] = context["datawidth"]
        context["dtype"] = memx.get_property("desyrdl_data_type") or "uint"
        context["signed"] = self.get_data_type_sign(memx)
        context["fixedpoint"] = self.get_data_type_fixed(memx)
        context["sw"] = memx.get_property("sw").name
        if not memx.is_sw_writable and memx.is_sw_readable:
            context["rw"] = "RO"
        elif memx.is_sw_writable and not memx.is_sw_readable:
            context["rw"] = "WO"
        else:
            context["rw"] = "RW"
        context['insts']  = list()
        context['reg_insts']  = list()
        context['regs']  = list()
        context['reg_types'] = list()
        context['reg_type_names'] = list()
        self.gen_items(memx, context)
        context['regs'] = self.unroll_inst('reg_insts',context)
        context['n_reg_insts'] = len(context['reg_insts'])
        context['n_regs'] = len(context['regs'])


    # =========================================================================
    def gen_rfitem (self, regf: RegfileNode, context):
        context['insts']  = list()
        context['reg_insts'] = list()
        context['regs']  = list()
        context['reg_types'] = list()
        context['reg_type_names'] = list()
        self.gen_items(regf, context)
        context['regs'] = self.unroll_inst('reg_insts',context)
        context['n_reg_insts'] = len(context['reg_insts'])
        context['n_regs'] = len(context['regs'])

    # =========================================================================
    def bitmask(self,width):
        '''
        Generates a bitmask filled with '1' with bit width equal to 'width'
        '''
        mask = 0
        for i in range(width):
            mask |= (1 << i)
        return mask

    # =========================================================================
    def to_int32(self,value):
        "make sure we have int32"
        masked = value & (pow(2,32)-1)
        if masked > pow(2,31):
             return -(pow(2,32)-masked)
        else:
            return masked

    # =========================================================================
    def get_access_channel(self, node):
        # Starting point for finding the top node
        cur_node = node
        ch = None
        while ch is None:
            try:
                ch = cur_node.get_property("desyrdl_access_channel")
                # The line above can return 'None' without raising an exception
                assert ch is not None
            except (LookupError,AssertionError):
                cur_node = cur_node.parent
                # The RootNode is above the top node and can't have the property
                # we are looking for.
                if isinstance(cur_node, RootNode):
                    print("ERROR: Couldn't find the access channel for " + node.inst_name)
                    raise
        return ch

    # =========================================================================
    def get_data_type_sign(self, node):
        datatype = str(node.get_property("desyrdl_data_type") or '')
        pattern = '(^int.*|^fixed.*)'
        if re.match(pattern, datatype):
            return 1
        else:
            return 0

    # =========================================================================
    def get_data_type_fixed(self, node):
        datatype = str(node.get_property("desyrdl_data_type") or '')
        pattern_fix = '.*fixed([-]*\d*)'
        pattern_fp = 'float'
        srch_fix = re.search(pattern_fix, datatype.lower())

        if srch_fix:
            if srch_fix.group(1) == '':
                return ''
            else:
                return int(srch_fix.group(1))

        if pattern_fp == datatype.lower():
            return 'IEEE754'

        return 0

###############################################################################
# Types, names and counts are needed. Clear after each exit_Addrmap
class DesyRdlProcessor(DesyListener):

    def __init__(self, tpl_dir, lib_dir, out_dir, out_formats):
        super().__init__()

        self.out_formats = out_formats
        self.lib_dir = lib_dir
        self.out_dir = out_dir

        self.generated_files = dict()
        self.generated_files['vhdl'] = list()
        self.generated_files['vhdl_dict'] = dict()
        self.generated_files['map'] = list()
        self.generated_files['h'] = list()
        self.generated_files['adoc'] = list()
        self.generated_files['tcl'] = list()
        self.generated_files["vhdl_dict"]["desyrdl"] = list() # inset desyrdl key so it is first on the list

        self.top_context['generated_files'] = self.generated_files

        # create Jinja template loaders, one loader per output type
        prefixLoaderDict = dict()
        for out_format in out_formats:
            prefixLoaderDict[out_format] =  jinja2.FileSystemLoader(Path(tpl_dir / out_format))
            prefixLoaderDict[out_format+"_lib"] =  jinja2.FileSystemLoader(Path(lib_dir / out_format))
        tplLoader = jinja2.PrefixLoader(prefixLoaderDict)

        self.jinja2Env = jinja2.Environment(
            loader=tplLoader,
            autoescape=jinja2.select_autoescape(),
            undefined=jinja2.StrictUndefined,
            line_statement_prefix="--#"
        )

    # =========================================================================
    def get_generated_files(self):
        return self.generated_files

    # =========================================================================
    def exit_Addrmap(self, node : AddrmapNode):
        super().exit_Addrmap(node)

        # formats to generate per address mapp
        if 'vhdl' in self.out_formats:
            if node.get_property('desyrdl_generate_hdl') is None or \
               node.get_property('desyrdl_generate_hdl') is True:
                print(f"VHDL for: {node.inst_name} ({node.type_name})")

                files = self.render_templates(loader="vhdl", outdir="vhdl", context=self.context)
                self.generated_files["vhdl"] = self.generated_files["vhdl"] + files
                self.generated_files["vhdl_dict"][node.inst_name] = files

        if 'adoc' in self.out_formats:
            print(f"ASCIIDOC for: {node.inst_name} ({node.type_name})")
            files = self.render_templates(loader="adoc", outdir="adoc",context=self.context)
            self.generated_files["adoc"] = self.generated_files["adoc"] + files

        # formats to generate on top
        if isinstance(node.parent, RootNode):
            if 'vhdl' in self.out_formats:
                files = self.render_templates(loader="vhdl_lib", outdir="vhdl", context=self.top_context)
                self.generated_files["vhdl"] = files + self.generated_files["vhdl"]
                self.generated_files["vhdl_dict"]["desyrdl"] = files

            if 'map' in self.out_formats:
                files = self.render_templates(loader="map", outdir="map",context=self.top_context)
                self.generated_files["map"] = self.generated_files["map"] + files

            if 'h' in self.out_formats:
                files = self.render_templates(loader="h", outdir="h",context=self.top_context)
                self.generated_files["h"] = self.generated_files["h"] + files

            if 'tcl' in self.out_formats:
                files = self.render_templates(loader="tcl", outdir="tcl",context=self.top_context)
                self.generated_files["tcl"] = self.generated_files["tcl"] + files

    # =========================================================================
    def render_templates (self, loader, outdir, context):
        generated_files = list()
        # get templates list and theyir ouput from include file
        template = self.jinja2Env.get_template(loader +"/include.txt")
        tpl_list = template.render(context).split()

        # render template list and save in out
        for tplidx in range(0,len(tpl_list),2):
            # get template
            template = self.jinja2Env.get_template(loader + "/" + tpl_list[tplidx])
            # create out dir if needed
            outFilePath = Path(self.out_dir / outdir / tpl_list[tplidx+1])
            outFilePath.parents[0].mkdir(parents=True,exist_ok=True)
            # render template and stream it directly to out file
            template.stream(context).dump(str(outFilePath.resolve()))
            generated_files.append(outFilePath)
            # self.generated_files[outdir].append(outFilePath)
        return generated_files

