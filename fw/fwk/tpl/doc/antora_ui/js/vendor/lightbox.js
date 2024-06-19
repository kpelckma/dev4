;(function () {
  'use strict'
  var lightbox

  function init () {
    if (!lightbox) {
      lightbox = document.createElement('div')
      lightbox.className = 'modal'
      lightbox.innerHTML = '<span class="close cursor">&times;</span>\n' +
        '  <div class="modal-content">\n' +
        '    <img alt="filled at runtime">\n' +
        '  </div>'

      var footer = document.getElementsByTagName('footer')[0]
      footer.parentNode.insertBefore(lightbox, footer.nextSibling)

      lightbox.getElementsByTagName('div')[0].onclick = closeModal
      lightbox.getElementsByTagName('span')[0].onclick = closeModal
    }
  }

  function openModal () {
    lightbox.style.display = 'block'
  }

  function closeModal () {
    lightbox.style.display = 'none'
  }

  document.querySelectorAll('.imageblock img').forEach(function (element) {
    if (element.parentNode.nodeName === 'A') {
      // if parent node is an anchor, keep the anchor instead of opening lightbox
      return
    }
    element.className += ' lightbox'
    element.addEventListener('click', function (evt) {
      init()
      lightbox.getElementsByTagName('img')[0].setAttribute('src', evt.currentTarget.getAttribute('src'))
      lightbox.getElementsByTagName('img')[0].setAttribute('alt', evt.currentTarget.getAttribute('alt'))
      openModal()
    })
  })
})()
