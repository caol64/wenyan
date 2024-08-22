// CodeMirror, copyright (c) by Marijn Haverbeke and others
// Distributed under an MIT license: http://codemirror.net/LICENSE

// Open search dialogs on top of an editor. Relies on dialog.css.

(function (mod) {
  if (typeof exports == "object" && typeof module == "object")
    // CommonJS
    mod(require("codemirror"));
  else if (typeof define == "function" && define.amd)
    // AMD
    define(["codemirror"], mod);
  // Plain browser env
  else mod(CodeMirror);
})((CodeMirror) => {
  let createPanel = (cm, template, bottom) => {
    let el = document.createElement("div");
    el.className = "CodeMirror-find-and-replace-dialog";

    if (typeof template == "string") {
      el.innerHTML = template;
    } else {
      // Assuming it's a detached DOM element.
      el.appendChild(template);
    }
    let panel = cm.addPanel(el, {
      position: bottom ? "bottom" : "top",
    });
    return panel;
  };

  let closePanel = (cm) => {
    let state = cm.state.findAndReplaceDialog;
    if (!state || !state.current) {
      return;
    }

    state.current.panel.clear();

    if (state.current.onClose) state.current.onClose(state.current.panel.node);
    delete state.current;
    cm.focus();
  };

  CodeMirror.defineExtension("openFindAndReplaceDialog", function (
    template,
    options
  ) {
    if (!this.addPanel) {
      throw `CodeMirror-FindAndReplaceDialog requires the panel addon to be included in the page.  This can usually be found in the addons folder of the default CodeMirror installation, and must be included BEFORE the FindAndReplaceDialog addon.`;
    }
    if (!options) options = {};
    if (!this.state.findAndReplaceDialog) this.state.findAndReplaceDialog = {};

    if (this.state.findAndReplaceDialog.current) {
      closePanel(this);
    }

    let panel = createPanel(this, template, options.bottom);
    this.state.findAndReplaceDialog.current = {
      panel: panel,
      onClose: options.onClose,
    };

    let inputs = panel.node.getElementsByTagName("input");
    let buttons = panel.node.getElementsByTagName("button");
    if (inputs && inputs.length > 0 && options.inputBehaviour) {
      for (let i = 0; i < options.inputBehaviour.length; i++) {
        let behaviour = options.inputBehaviour[i];
        let input = inputs[i];
        if (behaviour.value) {
          input.value = behaviour.value;
        }

        if (!!behaviour.focus) {
          input.focus();
        }

        if (!!behaviour.selectValueOnOpen) {
          input.select();
        }

        if (behaviour.onInput) {
          CodeMirror.on(input, "input", (e) => {
            behaviour.onInput(inputs, e);
          });
        }

        if (behaviour.onKeyUp) {
          CodeMirror.on(input, "keyup", (e) => {
            behaviour.onKeyUp(inputs, e);
          });
        }

        CodeMirror.on(input, "keydown", (e) => {
          if (behaviour.onKeyDown && behaviour.onKeyDown(inputs, e)) {
            return;
          }

          if (
            e.keyCode === 27 ||
            (!!behaviour.closeOnEnter && e.keyCode === 13)
          ) {
            input.blur();
            CodeMirror.e_stop(e);
            closePanel(this);
          } else if (e.keyCode === 13 && behaviour.callback) {
            CodeMirror.e_preventDefault(e);
            behaviour.callback(inputs, e);
          }
        });

        if (behaviour.closeOnBlur !== false)
          CodeMirror.on(input, "blur", () => {
            closePanel(this);
          });
      }
    }

    if (buttons && buttons.length > 0 && options.buttonBehaviour) {
      for (let i = 0; i < options.buttonBehaviour.length; i++) {
        let behaviour = options.buttonBehaviour[i];
        if (!!behaviour.callback) {
          CodeMirror.on(buttons[i], "click", (e) => {
            CodeMirror.e_preventDefault(e);
            behaviour.callback(inputs, e);
          });
        } else {
          CodeMirror.on(buttons[i], "click", (e) => {
            CodeMirror.e_preventDefault(e);
            closePanel(this);
          });
        }
      }
    }
    return () => {
      closePanel(this);
    };
  });
});
