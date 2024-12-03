/*
 * Copyright 2024 Lei Cao
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

const allowedTypeSelector = [
    '*',
    'h1',
    'h2',
    'h3',
    'h4',
    'h5',
    'h6',
    'p',
    'em',
    'strong',
    'ul',
    'ol',
    'li',
    'img',
    'table',
    'thead',
    'tbody',
    'th',
    'td',
    'tr',
    'blockquote',
    'code',
    'pre',
    'hr',
    'a',
    'span',
    'del'
];
const allowedClassSelector = ['footnote', 'footnote-num', 'footnote-txt'];
const allowedPseudoElement = ['before', 'after'];
const allowedPseudoClass = ['root', 'nth-child'];
const allowedPseudoElementSelector = ['h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'blockquote'];

function parseCss(css, compatibilityMode) {
    const formatedCss = fixPseudoElements(css);
    const ast = csstree.parse(formatedCss, {
        context: 'stylesheet',
        positions: false,
        parseAtrulePrelude: false,
        parseCustomProperty: false,
        parseValue: false
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
            if (node.name === 'html' || node.name === 'body') {
                list.insert(list.createItem({ type: 'IdSelector', name: 'wenyan' }), item);
                list.remove(item);
            } else if (!allowedTypeSelector.includes(node.name)) {
                list.clear();
            } else if (item.prev == null) {
                list.insert(list.createItem({ type: 'IdSelector', name: 'wenyan' }), item);
                list.insert(list.createItem({ type: 'Combinator', name: ' ' }), item);
            }
        }
    });

    if (compatibilityMode == 1) {
        csstree.walk(ast, {
            visit: 'ClassSelector',
            leave: (node, item, list) => {
                if (node.name === 'content') {
                    list.insert(list.createItem({ type: 'TypeSelector', name: 'span' }), item);
                    list.remove(item);
                } else if (node.name === 'suffix') {
                    if (item.prev != null && item.prev.data.type === 'Combinator' && item.prev.data.name === ' ') {
                        list.remove(item.prev);
                    }
                    list.insert(list.createItem({ type: 'PseudoElementSelector', name: 'after', children: null }), item);
                    list.remove(item);
                } else if (node.name === 'prefix') {
                    if (item.prev != null && item.prev.data.type === 'Combinator' && item.prev.data.name === ' ') {
                        list.remove(item.prev);
                    }
                    list.insert(list.createItem({ type: 'PseudoElementSelector', name: 'before', children: null }), item);
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
                list.insert(list.createItem({ type: 'IdSelector', name: 'wenyan' }), item);
                list.insert(list.createItem({ type: 'Combinator', name: ' ' }), item);
            }
        }
    });

    csstree.walk(ast, {
        visit: 'IdSelector',
        leave: (node, item, list) => {
            if (node.name !== 'wenyan' && node.name !== 'footnotes') {
                node.name = 'wenyan';
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
            if (node.children.isEmpty) {
                list.remove(item);
            }
        }
    });

    let imgs = 0;
    let tds = 0;
    let ths = 0;
    let tables = 0;

    csstree.walk(ast, {
        visit: 'Rule',
        leave: (node, item, list) => {
            if (node.block.children.isEmpty || node.prelude.children.isEmpty) {
                list.remove(item);
                return;
            }
            const element = node.prelude.children.head.data.children.head.data;
            if (element.type === 'PseudoClassSelector' && element.name !== 'root') {
                list.remove(item);
                return;
            }
            // console.log(element.type);
            if (element.type === 'PseudoElementSelector' || element.type === 'Combinator') {
                list.remove(item);
                return;
            }
            const lastElement = node.prelude.children.head.data.children.tail.data;
            if (lastElement.type === 'PseudoElementSelector') {
                if (!node.block.children.some((child) => child.property === 'content')) {
                    node.block.children.prepend(
                        list.createItem({
                            type: 'Declaration',
                            property: 'content',
                            value: { type: 'Value', children: [{ type: 'String', value: '' }] }
                        })
                    );
                }
            }
            if (lastElement.type === 'TypeSelector' && lastElement.name === 'img') {
                imgs ++;
                if (!node.block.children.some((child) => child.type === 'Declaration' && child.property === 'max-width')) {
                    node.block.children.prepend(
                        list.createItem({
                            type: 'Declaration',
                            property: 'max-width',
                            value: { type: 'Value', children: [{ type: 'Percentage', value: '100' }] }
                        })
                    );
                }
            }
            if (lastElement.type === 'TypeSelector' && lastElement.name === 'td') {
                tds ++;
                if (!node.block.children.some((child) => child.property === 'border')) {
                    node.block.children.prepend(
                        list.createItem({
                            type: 'Declaration',
                            property: 'border',
                            value: { type: 'Value', children: [
                                { type: 'Dimension', value: '1', unit: 'px' },
                                { type: 'Identifier', name: 'solid' },
                                { type: 'Hash', value: 'd8d8d8' }
                            ] }
                        })
                    );
                }
            }
            if (lastElement.type === 'TypeSelector' && lastElement.name === 'th') {
                ths ++;
                if (!node.block.children.some((child) => child.property === 'border')) {
                    node.block.children.prepend(
                        list.createItem({
                            type: 'Declaration',
                            property: 'border',
                            value: { type: 'Value', children: [
                                { type: 'Dimension', value: '1', unit: 'px' },
                                { type: 'Identifier', name: 'solid' },
                                { type: 'Hash', value: 'd8d8d8' }
                            ] }
                        })
                    );
                }
                if (!node.block.children.some((child) => child.property === 'font-weight')) {
                    node.block.children.prepend(
                        list.createItem({
                            type: 'Declaration',
                            property: 'font-weight',
                            value: { type: 'Value', children: [
                                { type: 'Identifier', name: 'bold' }
                            ] }
                        })
                    );
                }
                if (!node.block.children.some((child) => child.property === 'background-color')) {
                    node.block.children.prepend(
                        list.createItem({
                            type: 'Declaration',
                            property: 'background-color',
                            value: { type: 'Value', children: [
                                { type: 'Hash', value: 'f0f0f0' }
                            ] }
                        })
                    );
                }
            }
            if (lastElement.type === 'TypeSelector' && lastElement.name === 'table') {
                tables ++;
                if (!node.block.children.some((child) => child.property === 'border-collapse')) {
                    node.block.children.prepend(
                        list.createItem({
                            type: 'Declaration',
                            property: 'border-collapse',
                            value: { type: 'Value', children: [
                                { type: 'Identifier', name: 'collapse' }
                            ] }
                        })
                    );
                }
            }
        }
    });

    if (imgs === 0) {
        const defaultImgCss = `
#wenyan img {
    max-width: 100%;
    height: auto;
    margin: 0 auto;
    display: block;
}`;
        const defaultImgAST = csstree.parse(defaultImgCss, {
            context: 'stylesheet',
            positions: false,
            parseAtrulePrelude: false,
            parseCustomProperty: false,
            parseValue: false
        });
        ast.children.appendList(defaultImgAST.children);
    }

    if (tables === 0) {
        const defaultCss = `
#wenyan table {
    border-collapse: collapse;
    margin: 1.4em auto;
    max-width: 100%;
    table-layout: fixed;
    text-align: left;
    overflow: auto;
    display: inline-block;
    word-wrap: break-word;
    word-break: break-all;
}`;
        const defaultAST = csstree.parse(defaultCss, {
            context: 'stylesheet',
            positions: false,
            parseAtrulePrelude: false,
            parseCustomProperty: false,
            parseValue: false
        });
        ast.children.appendList(defaultAST.children);
    }

    if (tds === 0) {
        const defaultCss = `
#wenyan table td {
    font-size: 0.75em;
    height: 40px;
    padding: 9px 12px;
    line-height: 22px;
    color: #222;
    min-width: 60px;
    border: 1px solid #d8d8d8;
    vertical-align: top;
}`;
        const defaultAST = csstree.parse(defaultCss, {
            context: 'stylesheet',
            positions: false,
            parseAtrulePrelude: false,
            parseCustomProperty: false,
            parseValue: false
        });
        ast.children.appendList(defaultAST.children);
    }

    if (ths === 0) {
        const defaultCss = `
#wenyan table th {
    font-size: 0.75em;
    height: 40px;
    padding: 9px 12px;
    line-height: 22px;
    color: #222;
    min-width: 60px;
    border: 1px solid #d8d8d8;
    vertical-align: top;
    font-weight: bold;
    background-color: #f0f0f0;
}`;
        const defaultAST = csstree.parse(defaultCss, {
            context: 'stylesheet',
            positions: false,
            parseAtrulePrelude: false,
            parseCustomProperty: false,
            parseValue: false
        });
        ast.children.appendList(defaultAST.children);
    }

    const newCssContent = csstree.generate(ast);
    return newCssContent;
}



function fixPseudoElements(css) {
    // 匹配伪元素的单冒号形式，并替换为双冒号
    return css.replace(/([^:]):(before|after|first-line|first-letter)/g, '$1::$2');
}
