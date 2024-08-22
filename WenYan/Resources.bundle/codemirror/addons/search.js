// CodeMirror, copyright (c) by Marijn Haverbeke and others
// Distributed under an MIT license: http://codemirror.net/LICENSE

// Define search commands. Depends on find-and-replace-dialog.js

((mod) => {
  if (typeof exports == "object" && typeof module == "object")
    // CommonJS
    mod(require("codemirror"), require("codemirror-find-and-replace-dialog"));
  else if (typeof define == "function" && define.amd)
    // AMD
    define(["codemirror", "codemirror-find-and-replace-dialog"], mod);
  // Plain browser env
  else mod(CodeMirror);
})((CodeMirror) => {
  "use strict";

  var replaceDialog = `
      <div class="CodeMirror-find-and-replace-dialog--replace-container">
        <div class="CodeMirror-find-and-replace-dialog--row find">
          <div class="CodeMirror-find-and-replace-dialog--row">
            <input type="text" autocomplete="off" class="CodeMirror-find-and-replace-dialog--search-field" placeholder="Find" />
            <span class="CodeMirror-find-and-replace-dialog--search-count"></span>
          </div>
          <div class="CodeMirror-find-and-replace-dialog--buttons">
            <button class="CodeMirror-find-and-replace-dialog--find-previous" title="Find Previous">
              <svg xmlns="http://www.w3.org/2000/svg" width="9" height="5">
                <path d="M3.93.223a.84.84 0 011.14 0l3.697 3.492c.31.294.31.77 0 1.065a.832.832 0 01-1.127 0L4.5 1.814 1.36 4.78a.832.832 0 01-1.127 0 .726.726 0 010-1.065L3.931.223z" fill="#ACAEB1" fill-rule="evenodd"/>
              </svg>
            </button>
            <button class="CodeMirror-find-and-replace-dialog--find-next" title="Find Next">
              <svg xmlns="http://www.w3.org/2000/svg" width="9" height="5">
                <path d="M3.93 4.777a.84.84 0 001.14 0l3.697-3.492a.726.726 0 000-1.065.832.832 0 00-1.127 0L4.5 3.186 1.36.22a.832.832 0 00-1.127 0 .726.726 0 000 1.065l3.698 3.492z" fill="#ACAEB1" fill-rule="evenodd"/>
              </svg>
            </button>
            <button class="CodeMirror-find-and-replace-dialog--close" title="Close">
              <svg xmlns="http://www.w3.org/2000/svg" width="8" height="8">
                <path d="M.167.167a.572.572 0 01.808 0L4 3.192 7.025.167a.571.571 0 01.728-.066l.08.066a.572.572 0 010 .808L4.808 4l3.025 3.025c.198.198.22.506.066.728l-.066.08a.572.572 0 01-.808 0L4 4.808.975 7.833a.571.571 0 01-.728.066l-.08-.066a.572.572 0 010-.808L3.192 4 .167.975A.571.571 0 01.101.247z" fill="#ACAEB1" fill-rule="nonzero"/>
              </svg>
            </button>
          </div>
        </div>

        <div class="CodeMirror-find-and-replace-dialog--row replace">
          <div class="CodeMirror-find-and-replace-dialog--row">
            <input type="text" class="CodeMirror-find-and-replace-dialog--search-field" autocomplete="off" placeholder="Replace" />
          </div>
          <div class="CodeMirror-find-and-replace-dialog--buttons">
            <button class="CodeMirror-find-and-replace-dialog--replace" title="Replace">
              <svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path fill-rule="evenodd" clip-rule="evenodd" d="M3.221 3.739L5.482 6.008L7.7 3.784L7 3.084L5.988 4.091L5.98 2.491C5.97909 2.35567 6.03068 2.22525 6.12392 2.12716C6.21716 2.02908 6.3448 1.97095 6.48 1.965H8V1H6.48C6.28496 1.00026 6.09189 1.03902 5.91186 1.11405C5.73183 1.18908 5.56838 1.29892 5.43088 1.43725C5.29338 1.57558 5.18455 1.73969 5.11061 1.92018C5.03667 2.10066 4.99908 2.29396 5 2.489V4.1L3.927 3.033L3.221 3.739ZM9.89014 5.53277H9.90141C10.0836 5.84426 10.3521 6 10.707 6C11.0995 6 11.4131 5.83236 11.6479 5.49708C11.8826 5.1618 12 4.71728 12 4.16353C12 3.65304 11.8995 3.2507 11.6986 2.95652C11.4977 2.66234 11.2113 2.51525 10.8394 2.51525C10.4338 2.51525 10.1211 2.70885 9.90141 3.09604H9.89014V1H9V5.91888H9.89014V5.53277ZM9.87606 4.47177V4.13108C9.87606 3.88449 9.93427 3.6844 10.0507 3.53082C10.169 3.37724 10.3174 3.30045 10.4958 3.30045C10.6854 3.30045 10.831 3.37833 10.9324 3.53407C11.0357 3.68765 11.0873 3.9018 11.0873 4.17651C11.0873 4.50746 11.031 4.76379 10.9183 4.94549C10.8075 5.12503 10.6507 5.2148 10.4479 5.2148C10.2808 5.2148 10.1437 5.14449 10.0366 5.00389C9.92958 4.86329 9.87606 4.68592 9.87606 4.47177ZM9 12.7691C8.74433 12.923 8.37515 13 7.89247 13C7.32855 13 6.87216 12.8225 6.5233 12.4674C6.17443 12.1124 6 11.6543 6 11.0931C6 10.4451 6.18638 9.93484 6.55914 9.5624C6.93429 9.18747 7.43489 9.00001 8.06093 9.00001C8.49343 9.00001 8.80645 9.0596 9 9.17878V10.1769C8.76344 9.99319 8.4994 9.90132 8.20789 9.90132C7.88292 9.90132 7.62485 10.0006 7.43369 10.1993C7.24492 10.3954 7.15054 10.6673 7.15054 11.0149C7.15054 11.3526 7.24134 11.6183 7.42294 11.8119C7.60454 12.0031 7.85424 12.0987 8.17204 12.0987C8.454 12.0987 8.72999 12.0068 9 11.8231V12.7691ZM4 7L3 8V14L4 15H11L12 14V8L11 7H4ZM4 8H5H10H11V9V13V14H10H5H4V13V9V8Z" fill="#C5C5C5"/>
              </svg>
            </button>
            <button class="CodeMirror-find-and-replace-dialog--replace-all" title="Replace All">
              <svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path fill-rule="evenodd" clip-rule="evenodd" d="M11.6009 2.67683C11.7474 2.36708 11.9559 2.2122 12.2263 2.2122C12.4742 2.2122 12.6651 2.32987 12.7991 2.56522C12.933 2.80056 13 3.12243 13 3.53082C13 3.97383 12.9218 4.32944 12.7653 4.59766C12.6088 4.86589 12.3997 5 12.138 5C11.9014 5 11.7224 4.87541 11.6009 4.62622H11.5934V4.93511H11V1H11.5934V2.67683H11.6009ZM11.584 3.77742C11.584 3.94873 11.6197 4.09063 11.6911 4.20311C11.7624 4.3156 11.8538 4.37184 11.9653 4.37184C12.1005 4.37184 12.205 4.30002 12.2789 4.15639C12.354 4.01103 12.3915 3.80597 12.3915 3.54121C12.3915 3.32144 12.3571 3.15012 12.2883 3.02726C12.2207 2.90266 12.1236 2.84036 11.9972 2.84036C11.8782 2.84036 11.7793 2.9018 11.7005 3.02466C11.6228 3.14752 11.584 3.30759 11.584 3.50487V3.77742ZM4.11969 7.695L2 5.56781L2.66188 4.90594L3.66781 5.90625V4.39594C3.66695 4.21309 3.70219 4.03187 3.7715 3.86266C3.84082 3.69346 3.94286 3.53961 4.07176 3.40992C4.20066 3.28023 4.3539 3.17727 4.52268 3.10692C4.69146 3.03658 4.87246 3.00024 5.05531 3H7.39906V3.90469H5.05531C4.92856 3.91026 4.8089 3.96476 4.72149 4.05672C4.63408 4.14868 4.58571 4.27094 4.58656 4.39781L4.59406 5.89781L5.54281 4.95375L6.19906 5.61L4.11969 7.695ZM9.3556 4.93017H10V3.22067C10 2.40689 9.68534 2 9.05603 2C8.92098 2 8.77083 2.02421 8.6056 2.07263C8.44181 2.12104 8.3125 2.17691 8.21767 2.24022V2.90503C8.45474 2.70205 8.70474 2.60056 8.96767 2.60056C9.22917 2.60056 9.35991 2.75698 9.35991 3.06983L8.76078 3.17318C8.25359 3.25885 8 3.57914 8 4.13408C8 4.39665 8.06106 4.60708 8.18319 4.76536C8.30675 4.92179 8.47557 5 8.68966 5C8.97989 5 9.19899 4.83985 9.34698 4.51955H9.3556V4.93017ZM9.35991 3.57542V3.76816C9.35991 3.9432 9.31968 4.08845 9.23922 4.20391C9.15876 4.3175 9.0546 4.3743 8.92672 4.3743C8.83477 4.3743 8.76149 4.34264 8.7069 4.27933C8.65374 4.21415 8.62716 4.13128 8.62716 4.03073C8.62716 3.80912 8.73779 3.6797 8.95905 3.64246L9.35991 3.57542ZM7 12.9302H6.3556V12.5196H6.34698C6.19899 12.8399 5.97989 13 5.68966 13C5.47557 13 5.30675 12.9218 5.18319 12.7654C5.06106 12.6071 5 12.3966 5 12.1341C5 11.5791 5.25359 11.2588 5.76078 11.1732L6.35991 11.0698C6.35991 10.757 6.22917 10.6006 5.96767 10.6006C5.70474 10.6006 5.45474 10.702 5.21767 10.905V10.2402C5.3125 10.1769 5.44181 10.121 5.6056 10.0726C5.77083 10.0242 5.92098 10 6.05603 10C6.68534 10 7 10.4069 7 11.2207V12.9302ZM6.35991 11.7682V11.5754L5.95905 11.6425C5.73779 11.6797 5.62716 11.8091 5.62716 12.0307C5.62716 12.1313 5.65374 12.2142 5.7069 12.2793C5.76149 12.3426 5.83477 12.3743 5.92672 12.3743C6.0546 12.3743 6.15876 12.3175 6.23922 12.2039C6.31968 12.0885 6.35991 11.9432 6.35991 11.7682ZM9.26165 13C9.58343 13 9.82955 12.9423 10 12.8268V12.1173C9.81999 12.2551 9.636 12.324 9.44803 12.324C9.23616 12.324 9.06969 12.2523 8.94863 12.1089C8.82756 11.9637 8.76702 11.7644 8.76702 11.5112C8.76702 11.2505 8.82995 11.0466 8.95579 10.8994C9.08323 10.7505 9.25528 10.676 9.47192 10.676C9.66627 10.676 9.84229 10.7449 10 10.8827V10.1341C9.87097 10.0447 9.66229 10 9.37395 10C8.95659 10 8.62286 10.1406 8.37276 10.4218C8.12425 10.7011 8 11.0838 8 11.5698C8 11.9907 8.11629 12.3343 8.34887 12.6006C8.58144 12.8669 8.8857 13 9.26165 13ZM2 9L3 8H12L13 9V14L12 15H3L2 14V9ZM3 9V14H12V9H3ZM6 7L7 6H14L15 7V12L14 13V12V7H7H6Z" fill="#C5C5C5"/>
              </svg>
            </button>
          </div>
        </div>
      <div>
    `;

  var findDialog = `
      <div class="CodeMirror-find-and-replace-dialog--row find">
        <input type="text" class="CodeMirror-find-and-replace-dialog--search-field" autocomplete="off" placeholder="Find" />
        <span class="CodeMirror-find-and-replace-dialog--search-count"></span>
      </div>
      <div class="CodeMirror-find-and-replace-dialog--buttons">
        <button class="CodeMirror-find-and-replace-dialog--find-previous" title="Find Previous">
          <svg xmlns="http://www.w3.org/2000/svg" width="9" height="5">
            <path d="M3.93.223a.84.84 0 011.14 0l3.697 3.492c.31.294.31.77 0 1.065a.832.832 0 01-1.127 0L4.5 1.814 1.36 4.78a.832.832 0 01-1.127 0 .726.726 0 010-1.065L3.931.223z" fill="#ACAEB1" fill-rule="evenodd"/>
          </svg>
        </button>
        <button class="CodeMirror-find-and-replace-dialog--find-next" title="Find Next">
          <svg xmlns="http://www.w3.org/2000/svg" width="9" height="5">
            <path d="M3.93 4.777a.84.84 0 001.14 0l3.697-3.492a.726.726 0 000-1.065.832.832 0 00-1.127 0L4.5 3.186 1.36.22a.832.832 0 00-1.127 0 .726.726 0 000 1.065l3.698 3.492z" fill="#ACAEB1" fill-rule="evenodd"/>
          </svg>
        </button>
        <button class="CodeMirror-find-and-replace-dialog--close" title="Close">
          <svg xmlns="http://www.w3.org/2000/svg" width="8" height="8">
            <path d="M.167.167a.572.572 0 01.808 0L4 3.192 7.025.167a.571.571 0 01.728-.066l.08.066a.572.572 0 010 .808L4.808 4l3.025 3.025c.198.198.22.506.066.728l-.066.08a.572.572 0 01-.808 0L4 4.808.975 7.833a.571.571 0 01-.728.066l-.08-.066a.572.572 0 010-.808L3.192 4 .167.975A.571.571 0 01.101.247z" fill="#ACAEB1" fill-rule="nonzero"/>
          </svg>
        </button>
      </div>
    `;

  let numMatches = 0;
  let searchOverlay = (query, caseInsensitive) => {
    if (typeof query == "string")
      query = new RegExp(
        query.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&"),
        caseInsensitive ? "gi" : "g"
      );
    else if (!query.global)
      query = new RegExp(query.source, query.ignoreCase ? "gi" : "g");

    return {
      token: (stream) => {
        query.lastIndex = stream.pos;
        var match = query.exec(stream.string);
        if (match && match.index == stream.pos) {
          stream.pos += match[0].length || 1;
          return "searching";
        } else if (match) {
          stream.pos = match.index;
        } else {
          stream.skipToEnd();
        }
      },
    };
  };

  function SearchState() {
    this.posFrom = this.posTo = this.lastQuery = this.query = null;
    this.overlay = null;
  }

  let getSearchState = (cm) => {
    return cm.state.search || (cm.state.search = new SearchState());
  };

  let queryCaseInsensitive = (query) => {
    return typeof query == "string" && query == query.toLowerCase();
  };

  let getSearchCursor = (cm, query, pos) => {
    // Heuristic: if the query string is all lowercase, do a case insensitive search.
    return cm.getSearchCursor(
      parseQuery(query),
      pos,
      queryCaseInsensitive(query)
    );
  };

  let parseString = (string) => {
    return string.replace(/\\(.)/g, (_, ch) => {
      if (ch == "n") return "\n";
      if (ch == "r") return "\r";
      return ch;
    });
  };

  let parseQuery = (query) => {
    if (query.exec) {
      return query;
    }
    var isRE = query.indexOf("/") === 0 && query.lastIndexOf("/") > 0;
    if (!!isRE) {
      try {
        let matches = query.match(/^\/(.*)\/([a-z]*)$/);
        query = new RegExp(
          matches[1],
          matches[2].indexOf("i") == -1 ? "" : "i"
        );
      } catch (e) {} // Not a regular expression after all, do a string search
    } else {
      query = parseString(query);
    }
    if (typeof query == "string" ? query == "" : query.test("")) query = /x^/;
    return query;
  };

  /* Old */
  // let startSearch = (cm, state, query) => {
  //   if (!query || query === "") return;
  //   state.queryText = query;
  //   state.query = parseQuery(query);
  //   cm.removeOverlay(state.overlay, queryCaseInsensitive(state.query));
  //   state.overlay = searchOverlay(
  //     state.query,
  //     queryCaseInsensitive(state.query)
  //   );
  //   cm.addOverlay(state.overlay);
  //   if (cm.showMatchesOnScrollbar) {
  //     if (state.annotate) {
  //       state.annotate.clear();
  //       state.annotate = null;
  //     }
  //     state.annotate = cm.showMatchesOnScrollbar(
  //       state.query,
  //       queryCaseInsensitive(state.query)
  //     );
  //   }
  // };

  /* New */
  let startSearch = (cm, state, query) => {
    if (!query || query === "") return;
    state.queryText = query;
    state.query = parseQuery(query);
    // cm.removeOverlay(state.overlay, queryCaseInsensitive(state.query));
    cm.removeOverlay(state.overlay, true);
    state.overlay = searchOverlay(
      state.query,
      // queryCaseInsensitive(state.query)
      true
    );
    cm.addOverlay(state.overlay);
    if (cm.showMatchesOnScrollbar) {
      if (state.annotate) {
        state.annotate.clear();
        state.annotate = null;
      }
      state.annotate = cm.showMatchesOnScrollbar(
        state.query,
        // queryCaseInsensitive(state.query)
        true
      );
    }
  };

  let doSearch = (cm, query, reverse, moveToNext) => {
    var hiding = null;
    var state = getSearchState(cm);
    if (query != state.queryText) {
      startSearch(cm, state, query);
      state.posFrom = state.posTo = cm.getCursor();
    }
    if (moveToNext || moveToNext === undefined) {
      findNext(cm, reverse || false);
    }
    updateCount(cm);
  };

  let clearSearch = (cm) => {
    cm.operation(() => {
      var state = getSearchState(cm);
      state.lastQuery = state.query;
      if (!state.query) return;
      state.query = state.queryText = null;
      cm.removeOverlay(state.overlay);
      if (state.annotate) {
        state.annotate.clear();
        state.annotate = null;
      }
    });
  };

  let findNext = (cm, reverse, callback) => {
    cm.operation(() => {
      var state = getSearchState(cm);
      var cursor = getSearchCursor(
        cm,
        state.query,
        reverse ? state.posFrom : state.posTo
      );
      if (!cursor.find(reverse)) {
        cursor = getSearchCursor(
          cm,
          state.query,
          reverse
            ? CodeMirror.Pos(cm.lastLine())
            : CodeMirror.Pos(cm.firstLine(), 0)
        );
        if (!cursor.find(reverse)) return;
      }
      cm.setSelection(cursor.from(), cursor.to());
      cm.scrollIntoView(
        {
          from: cursor.from(),
          to: cursor.to(),
        },
        20
      );
      state.posFrom = cursor.from();
      state.posTo = cursor.to();
      if (callback) callback(cursor.from(), cursor.to());
    });
  };

  let replaceNext = (cm, query, text) => {
    let cursor = getSearchCursor(cm, query, cm.getCursor("from"));
    let start = cursor.from();
    let match = cursor.findNext();
    if (!match) {
      cursor = getSearchCursor(cm, query);
      match = cursor.findNext();
      if (
        !match ||
        (start &&
          cursor.from().line === start.line &&
          cursor.from().ch === start.ch)
      )
        return;
    }
    cm.setSelection(cursor.from(), cursor.to());
    cm.scrollIntoView({
      from: cursor.from(),
      to: cursor.to(),
    });
    cursor.replace(
      typeof query === "string"
        ? text
        : text.replace(/\$(\d)/g, (_, i) => {
            return match[i];
          })
    );
  };

  let replaceAll = (cm, query, text) => {
    cm.operation(() => {
      for (var cursor = getSearchCursor(cm, query); cursor.findNext(); ) {
        if (typeof query != "string") {
          var match = cm.getRange(cursor.from(), cursor.to()).match(query);
          cursor.replace(
            text.replace(/\$(\d)/g, (_, i) => {
              return match[i];
            })
          );
        } else cursor.replace(text);
      }
    });
  };

  let closeSearchCallback = (cm, state) => {
    if (state.annotate) {
      state.annotate.clear();
      state.annotate = null;
    }
    clearSearch(cm);
  };

  let getOnReadOnlyCallback = (callback) => {
    let closeFindDialogOnReadOnly = (cm, opt) => {
      if (opt === "readOnly" && !!cm.getOption("readOnly")) {
        callback();
        cm.off("optionChange", closeFindDialogOnReadOnly);
      }
    };
    return closeFindDialogOnReadOnly;
  };

  let updateCount = (cm) => {
    let state = getSearchState(cm);
    let value = cm.getDoc().getValue();
    let globalQuery;
    let queryText = state.queryText;

    if (!queryText || queryText === "") {
      resetCount(cm);
      return;
    }

    while (queryText.charAt(queryText.length - 1) === "\\") {
      queryText = queryText.substring(0, queryText.lastIndexOf("\\"));
    }

    if (typeof state.query === "string") {
      globalQuery = new RegExp(queryText, "ig");
    } else {
      globalQuery = new RegExp(state.query.source, state.query.flags + "g");
    }

    let matches = value.match(globalQuery);
    let count = matches ? matches.length : 0;

    let countText = count === 1 ? "1 match found." : count + " matches found.";
    cm
      .getWrapperElement()
      .parentNode.querySelector(
        ".CodeMirror-find-and-replace-dialog--search-count"
      ).innerHTML = countText;
    cm
      .getWrapperElement()
      .parentNode.querySelector(
        ".CodeMirror-find-and-replace-dialog--find-previous"
      ).disabled = count <= 0;
    cm
      .getWrapperElement()
      .parentNode.querySelector(
        ".CodeMirror-find-and-replace-dialog--find-next"
      ).disabled = count <= 0;
  };

  let resetCount = (cm) => {
    cm
      .getWrapperElement()
      .parentNode.querySelector(
        ".CodeMirror-find-and-replace-dialog--search-count"
      ).innerHTML = "";
    cm
      .getWrapperElement()
      .parentNode.querySelector(
        ".CodeMirror-find-and-replace-dialog--find-next"
      ).disabled = true;
    cm
      .getWrapperElement()
      .parentNode.querySelector(
        ".CodeMirror-find-and-replace-dialog--find-previous"
      ).disabled = true;
  };

  let getFindBehaviour = (cm, defaultText, callback) => {
    if (!defaultText) {
      defaultText = "";
    }
    let behaviour = {
      value: defaultText,
      focus: true,
      selectValueOnOpen: true,
      closeOnEnter: false,
      closeOnBlur: false,
      callback: (inputs, e) => {
        let query = inputs[0].value;
        if (!query) return;
        doSearch(cm, query, !!e.shiftKey);
      },
      onInput: (inputs, e) => {
        let query = inputs[0].value;
        if (!query) {
          resetCount(cm);
          clearSearch(cm);
          return;
        }
        doSearch(cm, query, !!e.shiftKey, false);
      },
    };
    if (!!callback) {
      behaviour.callback = callback;
    }
    return behaviour;
  };

  let getFindPrevBtnBehaviour = (cm) => {
    return {
      callback: (inputs) => {
        let query = inputs[0].value;
        if (!query) return;
        doSearch(cm, query, true);
      },
    };
  };

  let getFindNextBtnBehaviour = (cm) => {
    return {
      callback: (inputs) => {
        let query = inputs[0].value;
        if (!query) return;
        doSearch(cm, query, false);
      },
    };
  };

  let closeBtnBehaviour = {
    callback: null,
  };

  CodeMirror.commands.find = (cm) => {
    // if (cm.getOption("readOnly")) return;
    clearSearch(cm);
    let state = getSearchState(cm);
    var query = cm.getSelection() || getSearchState(cm).lastQuery;
    let closeDialog = cm.openFindAndReplaceDialog(findDialog, {
      shrinkEditor: true,
      inputBehaviour: [getFindBehaviour(cm, query)],
      buttonBehaviour: [
        getFindPrevBtnBehaviour(cm),
        getFindNextBtnBehaviour(cm),
        closeBtnBehaviour,
      ],
      onClose: () => {
        closeSearchCallback(cm, state);
      },
    });

    cm.on("optionChange", getOnReadOnlyCallback(closeDialog));
    startSearch(cm, state, query);
    updateCount(cm);
  };

  CodeMirror.commands.replace = (cm, all) => {
    if (cm.getOption("readOnly")) return;
    clearSearch(cm);

    let replaceNextCallback = (inputs) => {
      let query = parseQuery(inputs[0].value);
      let text = parseString(inputs[1].value);
      if (!query) return;
      replaceNext(cm, query, text);
      doSearch(cm, query);
    };

    let state = getSearchState(cm);
    let query = cm.getSelection() || state.lastQuery;
    let closeDialog = cm.openFindAndReplaceDialog(replaceDialog, {
      shrinkEditor: true,
      inputBehaviour: [
        getFindBehaviour(cm, query, (inputs) => {
          inputs[1].focus();
          inputs[1].select();
        }),
        {
          closeOnEnter: false,
          closeOnBlur: false,
          callback: replaceNextCallback,
        },
      ],
      buttonBehaviour: [
        getFindPrevBtnBehaviour(cm),
        getFindNextBtnBehaviour(cm),
        closeBtnBehaviour,
        {
          callback: replaceNextCallback,
        },
        {
          callback: (inputs) => {
            // Replace all
            let query = parseQuery(inputs[0].value);
            let text = parseString(inputs[1].value);
            if (!query) return;
            replaceAll(cm, query, text);
          },
        },
      ],
      onClose: () => {
        closeSearchCallback(cm, state);
      },
    });

    cm.on("optionChange", getOnReadOnlyCallback(closeDialog));
    startSearch(cm, state, query);
    updateCount(cm);
  };
});
