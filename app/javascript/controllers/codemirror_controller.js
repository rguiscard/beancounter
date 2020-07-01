// Visit The Stimulus Handbook for more details 
// https://stimulusjs.org/handbook/introduction
// 
// This example controller works with specially annotated HTML like:
//
// <div data-controller="hello">
//   <h1 data-target="hello.output"></h1>
// </div>

import { Controller } from "stimulus"

const snippets = [
  { text: 'const', displayText: 'const declarations' },
  { text: 'let', displayText: 'let declarations' },
  { text: 'var', displayText: 'var declarations' },
]

function dates() {
  let startDate = Date.now()
  let currentDate = Date.now()
  let endDate = new Date(Date.now()-60*60*24*30*1000)
  let dateArray = new Array()
  while(currentDate > endDate) {
    let s = new Date(currentDate).toISOString().substr(0,10)
    dateArray.push({ text: s+" ", displayText: s })
    currentDate = new Date(currentDate-60*60*24*1000)
    console.log(currentDate)
  }
  return dateArray
}

function getBackwardCharacter(instance) {
  let curretCursorPosition = instance.getCursor();
  let backwardCursorPosition = {
    line: curretCursorPosition.line,
    ch: curretCursorPosition.ch - 1
  };
  let backwardCharacter = instance.getRange(backwardCursorPosition, curretCursorPosition);
  return backwardCharacter
}

function getForwardCharacter(instance) {
  let curretCursorPosition = instance.getCursor();
  let forwardCursorPosition = {
    line: curretCursorPosition.line,
    ch: curretCursorPosition.ch + 1
  };
  let forwardCharacter = instance.getRange(curretCursorPosition, forwardCursorPosition);
  return forwardCharacter
}

export default class extends Controller {
  static targets = [ "input", "account" ]

  connect() {
    var cm = CodeMirror.fromTextArea(this.inputTarget, {
      lineNumbers: true,
      styleActiveLine: true,
    })

    var this_ = this

    cm.setOption('extraKeys', {
      'Cmd-Y': function() {
        this_.snippet(cm, snippets)
      },
      'Ctrl-Y': function() {
        this_.snippet(cm, snippets)
      },
      'Ctrl-Space': function() {
        this_.snippet(cm, snippets)
      },
      "'@'": function(cm) {
        var charTomatch = '@';
        var curretCursorPosition = cm.getCursor();
        var backwardCharacter = getBackwardCharacter(cm)
        var forwardCharacter = getForwardCharacter(cm)
        //update text anyway
        cm.replaceRange(charTomatch, curretCursorPosition);
        //
        if (backwardCharacter === charTomatch || forwardCharacter === charTomatch) {
          this_.snippet(cm, dates(), "@@")
        }
      },
      "'#'": function(cm) {
        var charTomatch = '#';
        var curretCursorPosition = cm.getCursor();
        var backwardCharacter = getBackwardCharacter(cm)
        var forwardCharacter = getForwardCharacter(cm)
        //update text anyway
        cm.replaceRange(charTomatch, curretCursorPosition);
        //
        let accounts = this_.accountTargets.map(function(x) {
          return { text: x.innerText, displayText: x.innerText }
        })
        if (backwardCharacter === charTomatch || forwardCharacter === charTomatch) {
          this_.snippet(cm, accounts, "##")
        }
      }
    })
  }

  snippet(instance, snippets, match) {
    CodeMirror.showHint(instance, function () {
      const cursor = instance.getCursor()
      const token = instance.getTokenAt(cursor)
      // const start = token.start // Without mode, token contain the whole line.
      const start = token.string.indexOf(match)
      const end = cursor.ch
      const line = cursor.line
      const currentWord = token.string
    
      console.log(token, start, end)

      const list = snippets.filter(function (item) {
        return item.text.indexOf(currentWord) >= 0
      })

      return {
        list: list.length ? list : snippets,
        from: CodeMirror.Pos(line, start),
        to: CodeMirror.Pos(line, end)
      }
    }, { completeSingle: false })
  }
}
