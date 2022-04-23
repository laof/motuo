var f = 'flutter'

function updateList() {
  var body = []
  var list = []
  try {
    list = localStorage.getItem(f)

    if (list) {
      list = JSON.parse(list)
    } else {
      list = []
    }
  } catch (e) {}

  list.forEach(function (data, index) {
    body.push('<li>' + _add(data).join('') + '</li>')
  })

  document.querySelector('#data_list').innerHTML = body.join('')
}

updateList()

function guid() {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
    var r = (Math.random() * 16) | 0,
      v = c == 'x' ? r : (r & 0x3) | 0x8
    return v.toString(16)
  })
}

function _add(data) {
  var td = []

  td.push(
    '<div class="delete" ><a onclick="del(this)">delete</a></div><input placeholder="key" value="' +
      (data.key || '') +
      '"  /><input placeholder="value"  value="' +
      (data.value || '') +
      '"  />',
  )
  return td
}
function add() {
  var cc = _add({})
  var tr = document.createElement('li')
  tr.innerHTML = cc.join('')
  document.querySelector('#data_list').prepend(tr)
}

function del(node) {
  document
    .querySelector('#data_list')
    .removeChild(node.parentElement.parentElement)
}

function save() {
  var nodes = document.querySelectorAll('#data_list li')

  var list = []

  nodes = Array.prototype.slice.call(nodes)
  nodes.forEach((ele, index) => {
    const [key, value] = ele.querySelectorAll('input')

    if (!key.value || window[key.value] || !key.value) {
      return
    }

    list.push({
      key: key.value,
      value: value.value,
    })
  })

  if (list.length) {
    localStorage.setItem(f, JSON.stringify(list))
  } else {
    localStorage.removeItem(f)
  }

  console.log(JSON.stringify(list))

  updateList()
}
