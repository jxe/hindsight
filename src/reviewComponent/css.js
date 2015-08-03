export default function css(x){
  document.head.insertAdjacentHTML(
    'beforeend',
    `<link rel="stylesheet" href="${x}.css">`
  )
}
