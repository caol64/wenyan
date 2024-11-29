const allowedTypeSelector = ["*", "h1", "h2", "h3", "h4", "h5", "h6", "p", "em", "strong", "ul", "ol", "li", "img", "table", "thead", "th", "td", "tr", "blockquote", "code", "pre", "hr", "a", "span", "del"];
const allowedClassSelector = ["footnote", "footnote-num", "footnote-txt"];
const allowedPseudoElement = ["before", "after"];
const allowedPseudoClass = ["root", "nth-child"];
const allowedPseudoElementSelector = ["h1", "h2", "h3", "h4", "h5", "h6", "blockquote"];

function parseCss(css, compatibilityMode) {
  const ast = csstree.parse(css, {
    context: "stylesheet",
    positions: false,
    parseAtrulePrelude: false,
    parseCustomProperty: false,
    parseValue: false,
  });

  csstree.walk(ast, {
    visit: 'Atrule',
    leave: (node, item, list) => {
      list.remove(item);
    }
  });

  csstree.walk(ast, {
    visit: 'AttributeSelector',
    leave: (node, item, list) => {
      list.clear();
    }
  });

  csstree.walk(ast, {
    visit: 'TypeSelector',
    leave: (node, item, list) => {
      if (node.name === "html" || node.name === "body") {
        list.insert(list.createItem({type: "IdSelector", name: "wenyan"}), item);
        list.remove(item);
      } else if (!allowedTypeSelector.includes(node.name)) {
        list.clear();
      } else if (item.prev == null) {
        list.insert(list.createItem({type: "IdSelector", name: "wenyan"}), item);
        list.insert(list.createItem({type: "Combinator", name: " "}), item);
      }
    }
  });

  if (compatibilityMode == 1) {
    csstree.walk(ast, {
      visit: 'ClassSelector',
      leave: (node, item, list) => {
        if (node.name === "content") {
          list.insert(list.createItem({type: "TypeSelector", name: "span"}), item);
          list.remove(item);
        } else if (node.name === "suffix") {
          if (item.prev != null && item.prev.data.type === "Combinator" && item.prev.data.name === " ") {
            list.remove(item.prev);
          }
          list.insert(list.createItem({type: "PseudoElementSelector", name: "after", children: null}), item);
          list.remove(item);
        } else if (node.name === "prefix") {
          if (item.prev != null && item.prev.data.type === "Combinator" && item.prev.data.name === " ") {
            list.remove(item.prev);
          }
          list.insert(list.createItem({type: "PseudoElementSelector", name: "before", children: null}), item);
          list.remove(item);
        }
      }
    });
  }

  csstree.walk(ast, {
    visit: 'ClassSelector',
    leave: (node, item, list) => {
      if (!allowedClassSelector.includes(node.name)) {
        list.clear();
      } else if (item.prev == null) {
        list.insert(list.createItem({type: "IdSelector", name: "wenyan"}), item);
        list.insert(list.createItem({type: "Combinator", name: " "}), item);
      }
    }
  });

  csstree.walk(ast, {
    visit: 'IdSelector',
    leave: (node, item, list) => {
      if (node.name !== "wenyan" && node.name !== "footnotes") {
        node.name = "wenyan";
      }
    }
  });

  csstree.walk(ast, {
    visit: 'PseudoElementSelector',
    leave: (node, item, list) => {
      if (!allowedPseudoElement.includes(node.name)) {
        list.clear();
      }
    }
  });

  csstree.walk(ast, {
    visit: 'PseudoClassSelector',
    leave: (node, item, list) => {
      if (!allowedPseudoClass.includes(node.name)) {
        list.clear();
      }
    }
  });

  csstree.walk(ast, {
    visit: 'Selector',
    leave: (node, item, list) => {
      // console.log(node);
      if (node.children.isEmpty) {
        list.remove(item);
      }
    }
  });

  csstree.walk(ast, {
    visit: 'Rule',
    leave: (node, item, list) => {
      if (node.block.children.isEmpty || node.prelude.children.isEmpty) {
        list.remove(item);
        return;
      }
      const element = node.prelude.children.head.data.children.head.data;
      if (element.type === "PseudoClassSelector" && element.name !== "root") {
        list.remove(item);
        return;
      }
      // console.log(element.type);
      if (element.type === "PseudoElementSelector" || element.type === "Combinator") {
        list.remove(item);
        return;
      }
      if (node.prelude.children.head.data.children.some(child => child.type === "PseudoElementSelector")) {
        if (!node.block.children.some(child => child.property === "content")) {
          node.block.children.prepend(list.createItem({type: "Declaration", property: "content", value: {type: "Value", children: [{type: "String", value: ""}]}}));
        }
      }
      if (node.prelude.children.head.data.children.some(child => child.type === "TypeSelector" && child.name === "img")) {
        node.block.children.prepend(list.createItem({type: "Declaration", property: "max-width", value: {type: "Value", children: [{type: "Percentage", value: "100"}]}}));
      }
    }
  });

  const imgs = csstree.findAll(ast, (node, item, list) =>
    node.type === 'TypeSelector' && node.name === 'img'
  );

  if (imgs.length === 0) {
    const defaultImgCss = `
#wenyan img {
    max-width: 100%;
    height: auto;
    margin: 0 auto;
    display: block;
}`;
    const defaultImgAST = csstree.parse(defaultImgCss, {
      context: "stylesheet",
      positions: false,
      parseAtrulePrelude: false,
      parseCustomProperty: false,
      parseValue: false,
    });
    ast.children.appendList(defaultImgAST.children);
  }

  const newCssContent = csstree.generate(ast);
  return newCssContent;
}
