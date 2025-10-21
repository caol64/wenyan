var WenyanStyles=(function(e){"use strict";const i=`#wenyan pre::before {
    display: block;
    content: "";
    background: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="45" height="12" viewBox="0 0 450 130"><ellipse cx="65" cy="65" rx="50" ry="52" stroke="rgb(220,60,54)" stroke-width="2" fill="rgb(237,108,96)"/><ellipse cx="225" cy="65" rx="50" ry="52"  stroke="rgb(218,151,33)" stroke-width="2" fill="rgb(247,193,81)"/><ellipse cx="385" cy="65" rx="50" ry="52" stroke="rgb(27,161,37)" stroke-width="2" fill="rgb(100,200,86)"/></svg>');
    background-repeat: no-repeat;
    width: 100%;
    height: 16px;
}`,s=[{id:"default",name:"Default",description:"A clean, classic layout ideal for long-form reading.",appName:"默认",author:""},{id:"orangeheart",name:"OrangeHeart",description:"A vibrant and elegant theme in warm orange tones.",appName:"Orange Heart",author:"evgo2017"},{id:"rainbow",name:"Rainbow",description:"A colorful, lively theme with a clean layout.",appName:"Rainbow",author:"thezbm"},{id:"lapis",name:"Lapis",description:"A minimal and refreshing theme in cool blue tones.",appName:"Lapis",author:"YiNN"},{id:"pie",name:"Pie",description:"Inspired by sspai.com and Misty — modern, sharp, and stylish.",appName:"Pie",author:"kevinzhao2233"},{id:"maize",name:"Maize",description:"A crisp, light theme with a soft maize palette.",appName:"Maize",author:"BEATREE"},{id:"purple",name:"Purple",description:"Clean and minimalist, with a subtle purple accent.",appName:"Purple",author:"hliu202"},{id:"phycat",name:"Phycat",description:"物理猫-薄荷：a mint-green theme with clear structure and hierarchy.",appName:"物理猫-薄荷",author:"sumruler"}],r=Object.assign({"./themes/default.css":()=>Promise.resolve().then(()=>b).then(n=>n.default),"./themes/juejin_default.css":()=>Promise.resolve().then(()=>w).then(n=>n.default),"./themes/lapis.css":()=>Promise.resolve().then(()=>f).then(n=>n.default),"./themes/maize.css":()=>Promise.resolve().then(()=>y).then(n=>n.default),"./themes/medium_default.css":()=>Promise.resolve().then(()=>u).then(n=>n.default),"./themes/orangeheart.css":()=>Promise.resolve().then(()=>x).then(n=>n.default),"./themes/phycat.css":()=>Promise.resolve().then(()=>j).then(n=>n.default),"./themes/pie.css":()=>Promise.resolve().then(()=>k).then(n=>n.default),"./themes/purple.css":()=>Promise.resolve().then(()=>v).then(n=>n.default),"./themes/rainbow.css":()=>Promise.resolve().then(()=>z).then(n=>n.default),"./themes/toutiao_default.css":()=>Promise.resolve().then(()=>_).then(n=>n.default),"./themes/zhihu_default.css":()=>Promise.resolve().then(()=>M).then(n=>n.default)});function d(n){const l=`./themes/${n.id}.css`,o=r[l];return o?{...n,getCss:o}:(console.warn(`[Themes] CSS file not found for theme: ${n.id}`),null)}const t=Object.fromEntries(s.map(n=>d(n)).filter(n=>n!==null).map(n=>[n.id,n]));function h(){return Object.values(t)}const c=Object.fromEntries(["juejin_default","medium_default","toutiao_default","zhihu_default"].map(n=>[n,{id:n,name:"",description:"",appName:"",author:"",getCss:r[`./themes/${n}.css`]}])),p=[{id:"atom-one-dark"},{id:"atom-one-light"},{id:"dracula"},{id:"github-dark"},{id:"github"},{id:"monokai"},{id:"solarized-dark"},{id:"solarized-light"},{id:"xcode"}],m=Object.assign({"./highlight/styles/atom-one-dark.min.css":()=>Promise.resolve().then(()=>T).then(n=>n.default),"./highlight/styles/atom-one-light.min.css":()=>Promise.resolve().then(()=>O).then(n=>n.default),"./highlight/styles/dracula.min.css":()=>Promise.resolve().then(()=>S).then(n=>n.default),"./highlight/styles/github-dark.min.css":()=>Promise.resolve().then(()=>I).then(n=>n.default),"./highlight/styles/github.min.css":()=>Promise.resolve().then(()=>P).then(n=>n.default),"./highlight/styles/monokai.min.css":()=>Promise.resolve().then(()=>D).then(n=>n.default),"./highlight/styles/solarized-dark.min.css":()=>Promise.resolve().then(()=>N).then(n=>n.default),"./highlight/styles/solarized-light.min.css":()=>Promise.resolve().then(()=>A).then(n=>n.default),"./highlight/styles/xcode.min.css":()=>Promise.resolve().then(()=>L).then(n=>n.default)}),a={};for(const n of p){const l=`./highlight/styles/${n.id}.min.css`,o=m[l];o?a[n.id]={...n,getCss:o}:console.warn(`[Highlight Themes] CSS file not found for theme: ${n.id}`)}function g(){return Object.values(a)}(function(n){n.macStyleCss=i,n.themes=t,n.hlThemes=a})(typeof window<"u"?window:void 0);const b=Object.freeze(Object.defineProperty({__proto__:null,default:`/**
 * 欢迎使用自定义主题功能，使用教程：
 * https://babyno.top/posts/2024/11/wenyan-supports-customized-themes/
 */
/* 全局属性 */
#wenyan {
    font-family: var(--sans-serif-font);
    line-height: 1.75;
    font-size: 16px;
}
/* 全局子元素属性 */
/* 支持分组 */
#wenyan h1,
#wenyan h2,
#wenyan h3,
#wenyan h4,
#wenyan h5,
#wenyan h6,
#wenyan p,
#wenyan pre {
    margin: 1em 0;
}
/* 段落 */
#wenyan p {
}
/* 加粗 */
#wenyan p strong {
}
/* 斜体 */
#wenyan p em {
}
/* 一级标题 */
#wenyan h1 {
    text-align: center;
    text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.1);
    font-size: 1.5em;
}
/* 标题文字 */
#wenyan h1 span {
}
/* 标题前缀，h1-h6都支持前缀 */
#wenyan h1::before {
}
/* 标题后缀，h1-h6都支持后缀 */
#wenyan h1::after {
}
/* 二级标题 */
#wenyan h2 {
    text-align: center;
    font-size: 1.2em;
    border-bottom: 1px solid #f7f7f7;
    font-weight: bold;
}
/* 三-六级标题 */
#wenyan h3,
#wenyan h4,
#wenyan h5,
#wenyan h6 {
    font-size: 1em;
    font-weight: bold;
}
/* 列表 */
#wenyan ul,
#wenyan ol {
    padding-left: 1.2em;
}
/* 列表元素 */
#wenyan li {
    margin-left: 1.2em;
}
/* 图片 */
#wenyan img {
    max-width: 100%;
    height: auto;
    margin: 0 auto;
    display: block;
}
/* 表格 */
#wenyan table {
    border-collapse: collapse;
    margin: 1.4em auto;
    max-width: 100%;
    table-layout: fixed;
    text-align: left;
    overflow: auto;
    display: table;
    word-wrap: break-word;
    word-break: break-all;
}
/* 表格单元格 */
#wenyan table td,
#wenyan table th {
    font-size: 0.75em;
    padding: 9px 12px;
    line-height: 22px;
    color: #222;
    border: 1px solid #d8d8d8;
    vertical-align: top;
}
/* 表格表头 */
#wenyan table th {
    font-weight: bold;
    background-color: #f0f0f0;
}
/* 表格斑马条纹效果 */
#wenyan table tr:nth-child(2n) {
    background-color: #f8f8f8;
}
/* 引用块 */
#wenyan blockquote {
    background: #afb8c133;
    border-left: 0.5em solid #ccc;
    margin: 1.5em 0;
    padding: 0.5em 10px;
    font-style: italic;
    font-size: 0.9em;
}
/* 引用块前缀 */
#wenyan blockquote::before {
}
/* 引用块后缀 */
#wenyan blockquote::after {
}
/* 行内代码 */
#wenyan p code {
    font-family: var(--monospace-font);
    color: #ff502c;
    padding: 4px 6px;
    font-size: 0.78em;
}
/* 代码块外围 */
#wenyan pre {
    border-radius: 5px;
    line-height: 2;
    margin: 1em 0.5em;
    padding: .5em;
    box-shadow: rgba(0, 0, 0, 0.55) 0px 1px 5px;
}
/* 代码块 */
#wenyan pre code {
    font-family: var(--monospace-font);
    display: block;
    overflow-x: auto;
    margin: .5em;
    padding: 0;
}
/* 分割线 */
#wenyan hr {
    border: none;
    border-top: 1px solid #ddd;
    margin-top: 2em;
    margin-bottom: 2em;
}
/* 链接 */
#wenyan a {
    word-wrap: break-word;
    color: #0069c2;
}
/* 原始链接旁脚注上标 */
#wenyan .footnote {
    color: #0069c2;
}
/* 脚注行 */
#wenyan #footnotes p {
    display: flex;
    margin: 0;
    font-size: 0.9em;
}
/* 脚注行内编号 */
#wenyan .footnote-num {
    display: inline;
    width: 10%;
}
/* 脚注行内文字 */
#wenyan .footnote-txt {
    display: inline;
    width: 90%;
    word-wrap: break-word;
    word-break: break-all;
}
`},Symbol.toStringTag,{value:"Module"})),w=Object.freeze(Object.defineProperty({__proto__:null,default:`#wenyan {
    font-family: var(--sans-serif-font);
    line-height: 1.75;
}
#wenyan * {
    box-sizing: border-box;
}
#wenyan h1,
#wenyan h2,
#wenyan h3,
#wenyan h4,
#wenyan h5,
#wenyan h6,
#wenyan p,
#wenyan pre {
    margin: 1em 0;
}
#wenyan h1,
#wenyan h2,
#wenyan h3,
#wenyan h4,
#wenyan h5,
#wenyan h6 {
    line-height: 1.5;
    margin-top: 35px;
    margin-bottom: 10px;
    padding-bottom: 5px;
}
#wenyan h1 {
    font-size: 24px;
    line-height: 38px;
    margin-bottom: 5px;
}
#wenyan h2 {
    font-size: 22px;
    line-height: 34px;
    padding-bottom: 12px;
    border-bottom: 1px solid #ececec;
}
#wenyan h3 {
    font-size: 20px;
    line-height: 28px;
}
#wenyan ul,
#wenyan ol {
    padding-left: 1.2em;
}
#wenyan li {
    margin-left: 1.2em;
}
#wenyan img {
    max-width: 100%;
    height: auto;
    margin: 0 auto;
    display: block;
}
#wenyan table {
    display: inline-block !important;
    font-size: 12px;
    width: auto;
    max-width: 100%;
    overflow: auto;
    border: 1px solid #f6f6f6;
}
#wenyan thead {
    background: #f6f6f6;
    color: #000;
    text-align: left;
}
#wenyan table td,
#wenyan table th {
    padding: 12px 7px;
    line-height: 24px;
}
#wenyan blockquote {
    color: #666;
    padding: 1px 23px;
    margin: 22px 0;
    border-left: 4px solid #cbcbcb;
    background-color: #f8f8f8;
    font-size: 0.95em;
}
#wenyan p code {
    font-family: var(--monospace-font);
    background: #fff5f5;
    color: #ff502c;
    padding: 4px 6px;
    font-size: 0.78em;
}
#wenyan pre {
    line-height: 2;
    margin: 1em 0.5em;
    padding: .5em;
    color: #333;
    background: #f8f8f8;
}
#wenyan pre code {
    font-family: var(--monospace-font);
    display: block;
    overflow-x: auto;
    margin: .5em;
    padding: 0;
    background: #f8f8f8;
}
#wenyan hr {
    border: none;
    border-top: 1px solid #ddd;
    margin-top: 32px;
    margin-bottom: 32px;
}
/* 链接 */
#wenyan a {
    word-wrap: break-word;
    color: #0069c2;
}
/* 脚注 */
#wenyan #footnotes ul {
    font-size: 0.9em;
    margin: 0;
    padding-left: 1.2em;
}
#wenyan #footnotes li {
    margin: 0 0 0 1.2em;
    overflow-wrap: break-word;
    word-wrap: break-word;
    word-break: break-all;
}
#wenyan .footnote {
    color: #0069c2;
}
`},Symbol.toStringTag,{value:"Module"})),f=Object.freeze(Object.defineProperty({__proto__:null,default:`/*
 *     Typora Theme - Lapis    /    Author - YiNN
 *     https://github.com/YiNNx/typora-theme-lapis
 */

:root {
    --text-color: #40464f;
    --primary-color: #4870ac;
    --bg-color: #ffffff;
    --marker-color: #a2b6d4;
    --source-color: #a8a8a9;
    --header-span-color: var(--primary-color);
    --block-bg-color: #f6f8fa;
}
#wenyan {
    color: var(--text-color);
    font-family: var(--sans-serif-font);
    line-height: 1.75;
    font-size: 16px;
}
#wenyan p,
#wenyan pre {
    margin: 1em 0;
}
#wenyan strong {
    color: var(--primary-color);
}
#wenyan a {
    word-wrap: break-word;
    color: var(--primary-color);
}
#wenyan p {
    color: var(--text-color);
}
#wenyan h4,
#wenyan h5,
#wenyan h6 {
    font-weight: normal;
}
#wenyan h1,
#wenyan h2,
#wenyan h3,
#wenyan h4,
#wenyan h5,
#wenyan h6 {
    padding: 0px;
    color: var(--primary-color);
    margin: 1.2em 0 1em;
}
#wenyan h1 {
    text-align: center;
}
#wenyan h2 {
    padding: 1px 12.5px;
    border-radius: 4px;
    display: inline-block;
}
#wenyan h2,
#wenyan h2 code {
    background-color: var(--header-span-color);
}
#wenyan h2,
#wenyan h2 a,
#wenyan h2 code,
#wenyan h2 strong {
    color: var(--bg-color);
}
#wenyan h1 {
    font-size: 1.5em;
}
#wenyan h2 {
    font-size: 1.3em;
}
#wenyan h3 {
    font-size: 1.3em;
}
#wenyan h4 {
    font-size: 1.2em;
}
#wenyan h5 {
    font-size: 1.2em;
}
#wenyan h6 {
    font-size: 1.2em;
}
#wenyan ul {
    list-style-type: disc;
}
#wenyan em {
    padding: 0 3px 0 0;
}
#wenyan ul ul {
    list-style-type: square;
}
#wenyan ol {
    list-style-type: decimal;
}
#wenyan blockquote {
    display: block;
    font-size: 0.9em;
    border-left: 3px solid var(--primary-color);
    padding: 0.5em 1em;
    margin: 0;
    background: var(--block-bg-color);
}
#wenyan p code {
    color: var(--primary-color);
    font-size: 0.9em;
    font-weight: normal;
    word-wrap: break-word;
    padding: 2px 4px 2px;
    border-radius: 3px;
    margin: 2px;
    background-color: var(--block-bg-color);
    font-family: var(--monospace-font);
    word-break: break-all;
}
#wenyan img {
    max-width: 100%;
    max-width: 100%;
    height: auto;
    margin: 0 auto;
    display: block;
}
#wenyan table {
    display: table;
    text-align: justify;
    overflow-x: auto;
    border-collapse: collapse;
    margin: 1.4em auto;
    max-width: 100%;
    table-layout: fixed;
    text-align: left;
    overflow: auto;
    word-wrap: break-word;
    word-break: break-all;
}
#wenyan table th,
#wenyan table td {
    border: 1px solid #d9dfe4;
    padding: 9px 12px;
    font-size: 0.75em;
    line-height: 22px;
    vertical-align: top;
}
#wenyan table th {
    text-align: center;
    font-weight: bold;
    color: var(--primary-color);
    background: #f7f7f7;
}
#wenyan hr {
    margin-top: 20px;
    margin-bottom: 20px;
    border: 0;
    border-top: 2px solid #eef2f5;
    border-radius: 2px;
}
#wenyan pre {
    border-radius: 5px;
    line-height: 2;
    margin: 1em 0.5em;
    padding: .5em;
    box-shadow: rgba(0, 0, 0, 0.55) 0px 1px 5px;
}
#wenyan pre code {
    display: block;
    overflow-x: auto;
    margin: .5em;
    padding: 0;
    font-family: var(--monospace-font);
}
#wenyan .footnote {
    color: var(--primary-color);
}
#wenyan #footnotes p {
    display: flex;
    margin: 0;
    font-size: 0.9em;
}
#wenyan .footnote-num {
    display: inline;
    width: 10%;
}
#wenyan .footnote-txt {
    display: inline;
    width: 90%;
    word-wrap: break-word;
    word-break: break-all;
}
`},Symbol.toStringTag,{value:"Module"})),y=Object.freeze(Object.defineProperty({__proto__:null,default:`/*
 *     Typora Theme - Maize    /    Author - BEATREE
 *     https://github.com/BEATREE/typora-maize-theme
 */

:root {
    --bg-color: #fafafa;
    --text-color: #333333;
    --primary-color: #428bca;
}
#wenyan {
    font-family: var(--sans-serif-font);
    line-height: 1.75;
    font-size: 16px;
}
#wenyan p,
#wenyan pre {
    margin: 1em 0;
}
#wenyan h1,
#wenyan h2,
#wenyan h3,
#wenyan h4,
#wenyan h5,
#wenyan h6 {
    margin: 1.2em 0 1em;
    padding: 0px;
    font-weight: bold;
}
#wenyan h1 {
    font-size: 1.5em;
}
#wenyan h2::before {
    content: "";
    width: 20px;
    height: 30px;
    background-image: url(data:image/svg+xml;base64,PHN2ZyB2aWV3Qm94PSIwIDAgMTAwIDEwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgdmVyc2lvbj0iMS4xIj4KICAgIDxnPgogICAgICAgIDxwYXRoIGQ9Im0zMy40NTIgNjIuMTQyUzY2LjA2MyAxNC45MzcgOTAuNDU2IDEwLjI4M2wxLjQyOSAxLjcxNFM3Mi41MzIgMjkuNTgyIDU4LjEzMyA0OC41ODNDNDMuMDg0IDY4LjQ0MiAzNi4wNTggODkuOTQ3IDMxLjg4IDg5LjcxNWMtNS42ODEtLjQxLTEyLjQyOS0zNy43MTYtMjMuMjg3LTMzLjI4Ny0yLjI4Ni0uNTcxIDMuOTEyLTkuNjE0IDEyLjU3Mi03LjU3MiA1LjQzIDEuMjgxIDEyLjI4NyAxMy4yODYgMTIuMjg3IDEzLjI4NnoiIGZpbGw9IiNmZmIxMWIiIC8+CiAgICA8L2c+Cjwvc3ZnPg==);
    background-repeat: no-repeat;
    background-size: 20px 20px;
    margin-right: 4px;
    background-position-y: 10px;
}
#wenyan h2 {
    font-size: 1.3em;
    display: flex;
    align-items: top;
}
#wenyan h2 span {
    font-weight: bold;
    color: #333;
    padding: 3px 10px 1px;
}
#wenyan h3 {
    font-size: 1.3em;
}
#wenyan h4 {
    font-size: 1.2em;
}
#wenyan h5 {
    font-size: 1.2em;
}
#wenyan h6 {
    font-size: 1.2em;
}
#wenyan ul,
#wenyan ol {
    margin-top: 8px;
    margin-bottom: 8px;
    padding-left: 40px;
    color: black;
}
#wenyan ul {
    list-style-type: disc;
}
#wenyan ul ul {
    list-style-type: square;
}
#wenyan ol {
    list-style-type: decimal;
}
#wenyan strong {
    color: #e49123;
    font-weight: bold;
}
#wenyan blockquote {
    margin: 0;
    padding: 10px 10px 10px 20px;
    font-size: 0.9em;
    background: #fff9f9;
    border-left: 3px solid #ffb11b;
    color: #6a737d;
    overflow: auto;
}
#wenyan a {
    word-wrap: break-word;
    text-decoration: none;
    font-weight: bold;
    color: #e49123;
    border-bottom: 1px solid #e49123;
}
#wenyan hr {
    height: 1px;
    padding: 0;
    border: none;
    text-align: center;
    background-image: linear-gradient(to right, rgba(231, 93, 109, 0.3), rgba(255, 159, 150, 0.75), rgba(255, 216, 181, 0.3));
}
#wenyan p code,
#wenyan span code,
#wenyan li code {
    font-family: var(--monospace-font);
    word-wrap: break-word;
    padding: 2px 4px;
    border-radius: 4px;
    margin: 0 2px;
    word-break: break-all;
    color: rgb(235, 76, 55);
    background-color: #f0f0f0;
    font-size: .8em;
}
#wenyan img {
    max-width: 100%;
    display: block;
    margin: 0 auto;
    width: 85%;
    border-radius: 5px;
    box-shadow: 0px 4px 12px #84a1a8;
    border: 0px;
}
#wenyan table {
    border-collapse: collapse;
    margin: 1.4em auto;
    max-width: 100%;
    table-layout: fixed;
    text-align: left;
    overflow: auto;
    display: table;
    word-wrap: break-word;
    word-break: break-all;
}
#wenyan table td,
#wenyan table th {
    font-size: 0.75em;
    padding: 9px 12px;
    line-height: 22px;
    color: #222;
    border: 1px solid rgb(255, 216, 181);
    vertical-align: top;
}
#wenyan table th {
    font-weight: bold;
    color: #ffb11b;
    background: #fff9f9;
}
#wenyan table tr:nth-child(2n) {
    background: #fff9f9;
}
#wenyan pre {
    border-radius: 5px;
    line-height: 2;
    margin: 1em 0.5em;
    padding: .5em;
    box-shadow: rgba(0, 0, 0, 0.55) 0px 1px 5px;
}
#wenyan pre code {
    display: block;
    overflow-x: auto;
    margin: .5em;
    padding: 0;
    font-family: var(--monospace-font);
}
#wenyan .footnote {
    font-weight: bold;
    color: #e49123;
}
#wenyan #footnotes p {
    display: flex;
    margin: 0;
    font-size: 0.9em;
}
#wenyan .footnote-num {
    display: inline;
    width: 10%;
}
#wenyan .footnote-txt {
    display: inline;
    width: 90%;
    word-wrap: break-word;
    word-break: break-all;
}
`},Symbol.toStringTag,{value:"Module"})),u=Object.freeze(Object.defineProperty({__proto__:null,default:`:root {
    --sans-serif-font: source-serif-pro, Georgia, Cambria, "Times New Roman", Times, serif;
    --monospace-font: Menlo, Monaco, Consolas, "liberation mono", "courier new", monospace;
}
#wenyan {
    font-family: var(--sans-serif-font);
    line-height: 1.75;
    font-size: 16px;
}
#wenyan * {
    box-sizing: border-box;
}
#wenyan h1,
#wenyan h2,
#wenyan h3,
#wenyan h4,
#wenyan h5,
#wenyan h6 {
    font-family: sohne, "Helvetica Neue", Helvetica, Arial, sans-serif;
    margin: 1em 0;
}
#wenyan h1 {
    font-size: 2em;
    font-weight: 700;
}
#wenyan h2,
#wenyan h3 {
    font-size: 1.3em;
    font-weight: 700;
}
#wenyan h4,
#wenyan h5,
#wenyan h6 {
    font-size: 1.2em;
    font-weight: 700;
}
#wenyan p {
    letter-spacing: -0.003em;
    margin: 1em 0;
}
#wenyan ul,
#wenyan ol {
    padding-left: 1.2em;
}
#wenyan li {
    margin-left: 1.2em;
}
#wenyan img {
    max-width: 100%;
    height: auto;
    margin: 0 auto;
    display: block;
}
#wenyan table {
    border-collapse: collapse;
    font-size: 15px;
    margin: 1.4em auto;
    max-width: 100%;
    table-layout: fixed;
    text-align: left;
    width: 100%;
    word-wrap: break-word;
    word-break: break-all;
}
#wenyan table th {
    background: #ebeced;
    color: #191b1f;
    font-weight: 500;
}
#wenyan table td,
#wenyan table th {
    border: 1px solid #c4c7ce;
    height: 24px;
    line-height: 24px;
    padding: 3px 12px;
}
#wenyan blockquote {
    letter-spacing: -0.003em;
    border-left: 3px solid rgba(0, 0, 0, 0.84);
    padding-left: 20px;
    margin: 0 0 20px 0;
}
#wenyan p code {
    padding: 4px 6px;
    font-size: 0.78em;
    border-radius: 3px;
    font-family: var(--monospace-font);
    background-color: #f2f2f2;
}
#wenyan pre {
    line-height: 2;
    margin: 1em 0.5em;
    padding: 1em;
    background: #f9f9f9;
    border-radius: 4px;
    border: 1px solid #e5e5e5;
}
#wenyan pre code {
    display: block;
    overflow-x: auto;
    margin: .5em;
    padding: 0;
    font-family: var(--monospace-font);
    background: #f9f9f9;
}
#wenyan hr {
    border: none;
    border-top: 1px solid #c4c7ce;
    margin: 2em auto;
    max-width: 100%;
    width: 240px;
}
/* 链接 */
#wenyan a {
    word-wrap: break-word;
    color: #000000;
}
/* 脚注 */
#wenyan #footnotes ul {
    font-size: 0.9em;
    margin: 0;
    padding-left: 1.2em;
}
#wenyan #footnotes li {
    margin: 0 0 0 1.2em;
    word-wrap: break-word;
    word-break: break-all;
}
#wenyan .footnote {
    color: #000000;
}
`},Symbol.toStringTag,{value:"Module"})),x=Object.freeze(Object.defineProperty({__proto__:null,default:`/*
 *     Typora Theme - Orange Heart    /    Author - evgo2017
 *     https://github.com/evgo2017/typora-theme-orange-heart
 */

#wenyan {
    font-family: var(--sans-serif-font);
    line-height: 1.75;
    font-size: 16px;
}
#wenyan p,
#wenyan pre {
    margin: 1em 0;
}
#wenyan h1,
#wenyan h2,
#wenyan h3,
#wenyan h4,
#wenyan h5,
#wenyan h6 {
    margin: 1.2em 0 1em;
    padding: 0px;
    font-weight: bold;
}
#wenyan h1 {
    font-size: 1.5em;
}
#wenyan h2 {
    font-size: 1.3em;
    border-bottom: 2px solid rgb(239, 112, 96);
    display: flex;
}
#wenyan h2 span {
    display: inline-block;
    font-weight: bold;
    background: rgb(239, 112, 96);
    color: #ffffff;
    padding: 3px 10px 1px;
    border-top-right-radius: 3px;
    border-top-left-radius: 3px;
    margin-right: 3px;
}
#wenyan h2::after {
    content: "";
    border-bottom: 36px solid #efebe9;
    border-right: 20px solid transparent;
    align-self: flex-end;
    height: 0;
}
#wenyan h3 {
    font-size: 1.3em;
}
#wenyan h4 {
    font-size: 1.2em;
}
#wenyan h5 {
    font-size: 1.1em;
}
#wenyan h6 {
    font-size: 1em;
}
#wenyan ul,
#wenyan ol {
    margin-top: 8px;
    margin-bottom: 8px;
    padding-left: 25px;
    color: black;
}
#wenyan ul {
    list-style-type: disc;
}
#wenyan ul ul {
    list-style-type: square;
}
#wenyan ol {
    list-style-type: decimal;
}
#wenyan blockquote {
    margin: 0;
    display: block;
    font-size: 0.9em;
    overflow: auto;
    border-left: 3px solid rgb(239, 112, 96);
    color: #6a737d;
    padding: 10px 10px 10px 20px;
    margin-bottom: 20px;
    margin-top: 20px;
    background: #fff9f9;
}
#wenyan a {
    text-decoration: none;
    word-wrap: break-word;
    font-weight: bold;
    color: rgb(239, 112, 96);
    border-bottom: 1px solid rgb(239, 112, 96);
}
#wenyan p code,
#wenyan li code {
    font-size: 0.9em;
    word-wrap: break-word;
    padding: 2px 4px;
    border-radius: 4px;
    margin: 0 2px;
    color: rgb(239, 112, 96);
    background-color: rgba(27, 31, 35, 0.05);
    font-family: var(--monospace-font);
    word-break: break-all;
}
#wenyan img {
    max-width: 100%;
    height: auto;
    margin: 0 auto;
    display: block;
}
#wenyan span img {
    max-width: 100%;
    display: inline-block;
    border-right: 0px;
    border-left: 0px;
}
#wenyan table {
    border-collapse: collapse;
    margin: 1.4em auto;
    max-width: 100%;
    table-layout: fixed;
    text-align: left;
    overflow: auto;
    display: table;
    word-wrap: break-word;
    word-break: break-all;
}
#wenyan table td,
#wenyan table th {
    font-size: 0.75em;
    padding: 9px 12px;
    line-height: 22px;
    color: #222;
    border: 1px solid rgb(239, 112, 96);
    vertical-align: top;
}
#wenyan table th {
    font-weight: bold;
    background-color: #fff9f9;
    color: rgb(239, 112, 96);
}
#wenyan span code,
#wenyan li code {
    color: rgb(239, 112, 96);
}
#wenyan pre {
    border-radius: 5px;
    line-height: 2;
    margin: 1em 0.5em;
    padding: .5em;
    box-shadow: rgba(0, 0, 0, 0.55) 0px 1px 5px;
}
#wenyan pre code {
    display: block;
    margin: .5em;
    padding: 0;
    font-family: var(--monospace-font);
}
#wenyan .footnote {
    color: rgb(239, 112, 96);
}
#wenyan #footnotes p {
    display: flex;
    margin: 0;
    font-size: 0.9em;
}
#wenyan .footnote-num {
    display: inline;
    width: 10%;
}
#wenyan .footnote-txt {
    display: inline;
    width: 90%;
    word-wrap: break-word;
    word-break: break-all;
}
`},Symbol.toStringTag,{value:"Module"})),j=Object.freeze(Object.defineProperty({__proto__:null,default:`/*
 *     Typora Theme - Phycat    /    Author - sumruler
 *     https://github.com/sumruler/typora-theme-phycat
 */

:root {
    /* 标题后小图标，借鉴自思源笔记主题——Savor */
    --h3-r-graphic: url("data:image/svg+xml;utf8,<svg fill='rgba(74, 200, 141, 0.5)' height='28' viewBox='0 0 32 32' width='24' xmlns='http://www.w3.org/2000/svg'><path d='M4.571 25.143c-1.257 0-2.286 1.029-2.286 2.286s1.029 2.286 2.286 2.286 2.286-1.029 2.286-2.286-1.029-2.286-2.286-2.286zM4.571 18.286c-1.257 0-2.286 1.029-2.286 2.286s1.029 2.286 2.286 2.286 2.286-1.029 2.286-2.286-1.029-2.286-2.286-2.286zM11.429 25.143c-1.257 0-2.286 1.029-2.286 2.286s1.029 2.286 2.286 2.286 2.286-1.029 2.286-2.286-1.029-2.286-2.286-2.286z'/></svg>")
        no-repeat center;
    --h4-r-graphic: url("data:image/svg+xml;utf8,<svg fill='rgba(74, 200, 141, 0.5)' height='24' viewBox='0 0 32 32' width='24' xmlns='http://www.w3.org/2000/svg'><path d='M4.571 25.143c-1.257 0-2.286 1.029-2.286 2.286s1.029 2.286 2.286 2.286 2.286-1.029 2.286-2.286-1.029-2.286-2.286-2.286zM4.571 18.286c-1.257 0-2.286 1.029-2.286 2.286s1.029 2.286 2.286 2.286 2.286-1.029 2.286-2.286-1.029-2.286-2.286-2.286zM11.429 25.143c-1.257 0-2.286 1.029-2.286 2.286s1.029 2.286 2.286 2.286 2.286-1.029 2.286-2.286-1.029-2.286-2.286-2.286zM11.429 22.857c1.257 0 2.286-1.029 2.286-2.286s-1.029-2.286-2.286-2.286-2.286 1.029-2.286 2.286 1.029 2.286 2.286 2.286z'/></svg>")
        no-repeat center;
    --h5-r-graphic: url("data:image/svg+xml;utf8,<svg fill='rgba(74, 200, 141, 0.5)' height='24' viewBox='0 0 32 32' width='24' xmlns='http://www.w3.org/2000/svg'><path d='M4.571 18.286c-1.257 0-2.286 1.029-2.286 2.286s1.029 2.286 2.286 2.286 2.286-1.029 2.286-2.286-1.029-2.286-2.286-2.286zM11.429 22.857c1.257 0 2.286-1.029 2.286-2.286s-1.029-2.286-2.286-2.286-2.286 1.029-2.286 2.286 1.029 2.286 2.286 2.286zM4.571 25.143c-1.257 0-2.286 1.029-2.286 2.286s1.029 2.286 2.286 2.286 2.286-1.029 2.286-2.286-1.029-2.286-2.286-2.286zM11.429 25.143c-1.257 0-2.286 1.029-2.286 2.286s1.029 2.286 2.286 2.286 2.286-1.029 2.286-2.286-1.029-2.286-2.286-2.286zM4.571 11.429c-1.257 0-2.286 1.029-2.286 2.286s1.029 2.286 2.286 2.286 2.286-1.029 2.286-2.286-1.029-2.286-2.286-2.286z'/></svg>")
        no-repeat center;
    --h6-r-graphic: url("data:image/svg+xml;utf8,<svg fill='rgba(74, 200, 141, 0.5)' height='24' viewBox='0 0 32 32' width='24' xmlns='http://www.w3.org/2000/svg'><path d='M4.571 25.143c-1.257 0-2.286 1.029-2.286 2.286s1.029 2.286 2.286 2.286 2.286-1.029 2.286-2.286-1.029-2.286-2.286-2.286zM4.571 18.286c-1.257 0-2.286 1.029-2.286 2.286s1.029 2.286 2.286 2.286 2.286-1.029 2.286-2.286-1.029-2.286-2.286-2.286zM4.571 11.429c-1.257 0-2.286 1.029-2.286 2.286s1.029 2.286 2.286 2.286 2.286-1.029 2.286-2.286-1.029-2.286-2.286-2.286zM11.429 18.286c-1.257 0-2.286 1.029-2.286 2.286s1.029 2.286 2.286 2.286 2.286-1.029 2.286-2.286-1.029-2.286-2.286-2.286zM11.429 25.143c-1.257 0-2.286 1.029-2.286 2.286s1.029 2.286 2.286 2.286 2.286-1.029 2.286-2.286-1.029-2.286-2.286-2.286zM11.429 16c1.257 0 2.286-1.029 2.286-2.286s-1.029-2.286-2.286-2.286-2.286 1.029-2.286 2.286 1.029 2.286 2.286 2.286z'/></svg>")
        no-repeat center;

    /* 是否开启网格背景？1 是；0 否 */
    --bg-grid: 0;

    /* 主题颜色 */

    --head-title-color: #3db8bf;
    /* 标题主色 */
    --head-title-h2-color: #fff;
    --head-title-h2-background: linear-gradient(to right, #3db8d3, #80f7c4);
    /* 二级标题主色，因为二级标题是背景色的，所以单独设置 */

    --element-color: #3db8bf;
    /* 元素主色 */
    --element-color-deep: #089ba3;
    /* 元素深色 */
    --element-color-shallow: #7aeaf0;
    /* 元素浅色 */
    --element-color-so-shallow: #7aeaf077;
    /* 元素很浅色 */
    --element-color-soo-shallow: #7aeaf018;
    /* 元素非常浅色 */

    --element-color-linecode: #089ba3;
    /* 行内代码文字色 */
    --element-color-linecode-background: #7aeaf018;
    /* 行内代码背景色 */
}
#wenyan {
    font-size: 14px;
    font-family: var(--sans-serif-font);
    margin: 0 auto;
    padding: 15px;
    line-height: 1.75;
    color: #000;
    letter-spacing: 1.1px;
    word-break: break-word;
    word-wrap: break-word;
    text-align: left;
    background-image: linear-gradient(
            90deg,
            rgba(50, 0, 0, 0.05) calc(3% * var(--bg-grid)),
            rgba(0, 0, 0, 0) calc(3% * var(--bg-grid))
        ),
        linear-gradient(
            360deg,
            rgba(50, 0, 0, 0.05) calc(3% * var(--bg-grid)),
            rgba(0, 0, 0, 0) calc(3% * var(--bg-grid))
        );
    background-size: 20px 20px;
    background-position: center center;
}
#wenyan p {
    text-align: justify;
    color: #333;
    margin: 10px 10px;
    word-spacing: 2px;
}
#wenyan h3::after,
#wenyan h4::after,
#wenyan h5::after,
#wenyan h6::after {
    content: "";
    margin-left: 0.2em;
    height: 2em;
    width: 1.2em;
}
#wenyan h3::after {
    background: var(--h3-r-graphic);
    background-position-y: -2px;
}
#wenyan h4::after {
    background: var(--h4-r-graphic);
    background-position-y: -2px;
}
#wenyan h5::after {
    background: var(--h5-r-graphic);
    background-position-y: -1px;
}
#wenyan h6::after {
    background: var(--h6-r-graphic);
    background-position-y: -1px;
}
#wenyan h1 {
    text-align: center;
    font-weight: bold;
    font-size: 1.4em;
}
#wenyan h2 {
    color: var(--head-title-h2-color);
    font-size: 1.4em;
    line-height: 1.6;
    width: fit-content;
    font-weight: bold;
    margin: 20px 0 5px;
    padding: 1px 12.5px;
    border-radius: 4px;
    background: var(--head-title-h2-background);
    background-size: 200% 100%;
    background-position: 0% 0%;
    display: inline-block;
}
#wenyan h3,
h4,
h5,
h6 {
    font-weight: bold;
    display: flex;
    align-items: top;
}
#wenyan h3 {
    width: fit-content;
    margin: 20px 0 5px;
    font-size: 1.3em;
    padding-left: 10px;
    border-left: 5px solid var(--head-title-color);
}
#wenyan h3 span {
    border-bottom: 2px hidden var(--head-title-color);
}
#wenyan h4 {
    margin: 20px 0 5px;
    font-size: 1.15em;
}
#wenyan h4::before {
    content: "";
    margin-right: 7px;
    margin-top: 8px;
    background-color: var(--head-title-color);
    width: 10px;
    height: 10px;
    border-radius: 100%;
    border: var(--head-title-color) 1px solid;
}
#wenyan h5 {
    margin: 20px 0 5px;
    font-size: 1.1em;
}
#wenyan h5::before {
    content: "";
    margin-right: 7px;
    margin-top: 8px;
    display: inline-block;
    background-color: #ffffff;
    width: 10px;
    height: 10px;
    border-radius: 100%;
    border: var(--head-title-color) 2px solid;
}
#wenyan h6 {
    margin: 20px 0 5px;
    font-size: 1.1em;
}
#wenyan h6::before {
    content: "⁘";
    color: var(--head-title-color);
    margin-right: 7px;
}

#wenyan ol {
    margin-left: 2px;
    padding-left: 12px;
    margin-bottom: 0px;
    margin-top: 0px;
}

#wenyan ul {
    list-style-type: disc;
    margin-bottom: 0px;
    margin-top: 0px;
}

#wenyan ul ul {
    list-style-type: circle;
}

#wenyan ul ul ul {
    list-style-type: square;
}

#wenyan ol {
    padding-left: 27px;
    list-style-type: decimal;
}
#wenyan ol ol {
    list-style-type: lower-alpha;
}
#wenyan ol ol ol {
    list-style-type: lower-roman;
}

#wenyan li {
    color: #333;
    margin: 0px 6px;
    word-spacing: 2px;
    line-height: 2.5;
}

#wenyan li {
    position: relative;
}
#wenyan li > p {
    margin: 0;
}
#wenyan blockquote {
    font-size: 12px;
    margin-left: 12px;
    text-align: justify;
    padding: 12px;
    background: var(--element-color-soo-shallow);
    border: 0px solid var(--element-color);
    border-left-color: var(--element-color);
    border-left-width: 4px;
    border-radius: 4px;
    line-height: 26px;
}
#wenyan blockquote p {
    color: #000;
}
#wenyan a {
    color: #000;
    font-weight: bolder;
    text-decoration: none;
    border-bottom: 1px solid #3db8bf;
}

#wenyan strong {
    color: #000;
    font-weight: bold;
}
#wenyan em {
    font-style: italic;
    color: #000;
}
#wenyan del {
    text-decoration-color: var(--element-color-deep);
}
#wenyan hr {
    height: 1px;
    padding: 0;
    border: none;
    border-top: 2px solid var(--head-title-color);
}
#wenyan img {
    max-width: 90%;
    display: block;
    border-radius: 6px;
    margin: 10px auto;
    object-fit: contain;
}
#wenyan p code {
    padding: 3px 3px 1px;
    color: var(--element-color-linecode);
    background: var(--element-color-linecode-background);
    border-radius: 3px;
    font-family: var(--monospace-font);
    letter-spacing: 0.5px;
}
#wenyan li code {
    color: var(--element-color-linecode);
}
#wenyan pre {
    border-radius: 5px;
    line-height: 2;
    margin: 1em 0.5em;
    padding: 0.5em;
    box-shadow: rgba(0, 0, 0, 0.55) 0px 1px 5px;
}
#wenyan pre code {
    font-family: var(--monospace-font);
    display: block;
    overflow-x: auto;
    margin: 0.5em;
    padding: 0;
}
#wenyan table {
    border-collapse: collapse;
    margin: 1.4em auto;
    max-width: 100%;
    table-layout: fixed;
    text-align: left;
    overflow: auto;
    display: table;
    word-wrap: break-word;
    word-break: break-all;
}
#wenyan table td,
#wenyan table th {
    font-size: 10px;
    padding: 9px 12px;
    line-height: 22px;
    color: #222;
    border: 1px solid var(--element-color-deep);
    vertical-align: top;
}
#wenyan table th {
    font-weight: bold;
    background-color: var(--element-color-soo-shallow);
    color: var(--element-color-deep);
}

#wenyan .footnote {
    color: var(--primary-color);
}
#wenyan #footnotes p {
    display: flex;
    margin: 0;
    font-size: 0.9em;
}
#wenyan .footnote-num {
    display: inline;
    width: 10%;
}
#wenyan .footnote-txt {
    display: inline;
    width: 90%;
    word-wrap: break-word;
    word-break: break-all;
}
`},Symbol.toStringTag,{value:"Module"})),k=Object.freeze(Object.defineProperty({__proto__:null,default:`/*
 *     Typora Theme - Pie    /    Author - kevinzhao2233
 *     https://github.com/kevinzhao2233/typora-theme-pie
 */

:root {
    --mid-1: #ffffff;
    --mid-7: #8c8c8c;
    --mid-9: #434343;
    --mid-10: #262626;
    --main-1: #fff2f0;
    --main-4: #f27f79;
    --main-5: #e6514e;
    --main-6: #da282a;
}
#wenyan {
    font-family: var(--sans-serif-font);
    line-height: 1.75;
    color: var(--mid-10);
    letter-spacing: 0;
    font-size: 16px;
}
#wenyan p,
#wenyan pre {
    margin: 1em 0;
}
#wenyan p {
    word-spacing: 0.05rem;
    text-align: justify;
}
#wenyan a {
    word-wrap: break-word;
    color: var(--main-6);
    text-decoration: none;
    border-bottom: 1px solid var(--main-6);
    transition: border-bottom 0.2s;
    padding: 0 2px;
    font-weight: 500;
    text-decoration: none;
}
#wenyan h1,
#wenyan h2,
#wenyan h3,
#wenyan h4,
#wenyan h5,
#wenyan h6 {
    position: relative;
    margin: 1.2em 0 1em;
    padding: 0px;
    font-weight: bold;
    cursor: text;
}
#wenyan h2 a,
#wenyan h3 a {
    color: var(--mid-9);
}
#wenyan h1 {
    font-size: 1.5em;
    text-align: center;
}
#wenyan h1::after {
    display: block;
    width: 100px;
    height: 2px;
    margin: 0.2em auto 0;
    content: "";
    border-bottom: 2px dashed var(--main-6);
}
#wenyan h2 {
    padding-left: 6px;
    margin: 2em auto 1.4em;
    font-size: 1.3em;
    border-left: 6px solid var(--main-6);
}
#wenyan h3 {
    font-size: 1.2em;
}
#wenyan h3::before {
    display: inline-block;
    width: 6px;
    height: 6px;
    margin-right: 6px;
    margin-bottom: 0.18em;
    line-height: 1.43;
    vertical-align: middle;
    content: "";
    background-color: var(--main-5);
    border-radius: 50%;
}
#wenyan h4 {
    font-size: 1.2em;
}
#wenyan h4::before {
    display: inline-block;
    width: 6px;
    height: 2px;
    margin-right: 8px;
    margin-bottom: 0.18em;
    vertical-align: middle;
    content: "";
    background-color: var(--main-4);
}
#wenyan h5 {
    font-size: 1.2em;
}
#wenyan h6 {
    font-size: 1.2em;
    color: var(--mid-7);
}
#wenyan li > ol,
#wenyan li > ul {
    margin: 0;
}
#wenyan hr {
    box-sizing: content-box;
    width: 100%;
    height: 1px;
    padding: 0;
    margin: 46px auto 64px;
    overflow: hidden;
    background-color: var(--main-4);
    border: 0;
}
#wenyan blockquote {
    position: relative;
    padding: 24px 16px 12px;
    margin: 24px 0 36px;
    font-size: 1em;
    font-style: normal;
    line-height: 1.6;
    color: var(--mid-7);
    text-indent: 0;
    border: none;
    border-left: 2px solid var(--main-6);
}
#wenyan blockquote blockquote {
    padding-right: 0;
}
#wenyan blockquote a {
    color: var(--mid-7);
}
#wenyan blockquote::before {
    position: absolute;
    top: 0;
    left: 12px;
    font-family: Arial, serif;
    font-size: 2em;
    font-weight: 700;
    line-height: 1em;
    color: var(--main-6);
    content: "“";
}
#wenyan table {
    border-collapse: collapse;
    margin: 1.4em auto;
    max-width: 100%;
    table-layout: fixed;
    text-align: left;
    overflow: auto;
    display: table;
    word-wrap: break-word;
    word-break: break-all;
}
#wenyan table td,
#wenyan table th {
    font-size: 0.75em;
    padding: 9px 12px;
    line-height: 22px;
    vertical-align: top;
    border: 1px solid var(--main-4);
}
#wenyan table th {
    font-weight: bold;
    color: var(--main-6);
    background-color: var(--main-1);
}
#wenyan strong {
    padding: 0 1px;
}
#wenyan em {
    padding: 0 5px 0 2px;
}
#wenyan p code {
    padding: 2px 4px 1px;
    margin: 0 2px;
    font-family: var(--monospace-font);
    font-size: 0.92rem;
    color: var(--main-5);
    background-color: var(--main-1);
    border-radius: 3px;
}
#wenyan p code {
    vertical-align: 0.5px;
}
#wenyan .footnote {
    color: var(--main-5);
    background-color: var(--main-1);
}
#wenyan img {
    max-width: 100%;
    display: block;
    margin: 0 auto;
    border-radius: 4px;
}
#wenyan pre {
    border-radius: 5px;
    line-height: 2;
    margin: 1em 0.5em;
    padding: .5em;
    box-shadow: rgba(0, 0, 0, 0.55) 0px 1px 5px;
}
#wenyan pre code {
    display: block;
    overflow-x: auto;
    margin: .5em;
    padding: 0;
    font-family: var(--monospace-font);
}
#wenyan .footnote {
    color: rgb(239, 112, 96);
}
#wenyan #footnotes p {
    display: flex;
    margin: 0;
    font-size: 0.9em;
}
#wenyan .footnote-num {
    display: inline;
    width: 10%;
}
#wenyan .footnote-txt {
    display: inline;
    width: 90%;
    word-wrap: break-word;
    word-break: break-all;
}
`},Symbol.toStringTag,{value:"Module"})),v=Object.freeze(Object.defineProperty({__proto__:null,default:`/*
 *     Typora Theme - Purple    /    Author - hliu202
 *     https://github.com/hliu202/typora-purple-theme
 */

:root {
    --title-color: #8064a9;
    --text-color: #444444;
    --link-color: #2aa899;
    --code-color: #745fb5;
    --shadow-color: #eee;
    --border-quote: rgba(116, 95, 181, 0.2);
    --border: #e7e7e7;
    --link-bottom: #bbb;
    --shadow: 3px 3px 10px var(--shadow-color);
    --inline-code-bg: #f4f2f9;
    --header-weight: normal;
}
#wenyan {
    font-family: var(--sans-serif-font);
    color: var(--text-color);
    line-height: 1.75;
    font-size: 16px;
}
#wenyan a {
    word-wrap: break-word;
    border-bottom: 1px solid var(--link-bottom);
    color: var(--link-color);
    text-decoration: none;
}
#wenyan h1,
#wenyan h2,
#wenyan h3,
#wenyan h4,
#wenyan h5,
#wenyan h6 {
    margin: 1.2em 0 1em;
    padding: 0px;
    font-weight: var(--header-weight);
    color: var(--title-color);
    font-family: var(--sans-serif-font);
}
#wenyan h1 {
    text-align: center;
}
#wenyan h1::after {
    content: "";
    display: block;
    margin: 0.2em auto 0;
    width: 6em;
    height: 2px;
    border-bottom: 2px solid var(--title-color);
}
#wenyan h2 {
    padding-left: 0.4em;
    border-left: 0.4em solid var(--title-color);
    border-bottom: 1px solid var(--title-color);
}
#wenyan h1 {
    font-size: 1.5em;
}
#wenyan h2 {
    font-size: 1.3em;
}
#wenyan h3 {
    font-size: 1.2em;
}
#wenyan h4 {
    font-size: 1.2em;
}
#wenyan h5 {
    font-size: 1.2em;
}
#wenyan h6 {
    font-size: 1.2em;
}
#wenyan p,
#wenyan ul,
#wenyan ol {
    margin: 1em 0.8em;
}
#wenyan hr {
    margin: 1.5em auto;
    border-top: 1px solid var(--border);
}
#wenyan li > ol,
#wenyan li > ul {
    margin: 0 0;
}
#wenyan ul,
#wenyan ol {
    padding-left: 2em;
}
#wenyan ol li,
#wenyan ul li {
    padding-left: 0.1em;
}
#wenyan blockquote {
    margin: 0;
    border-left: 0.3em solid var(--border-quote);
    padding-left: 1em;
}
#wenyan table {
    border-collapse: collapse;
    margin: 1.4em auto;
    max-width: 100%;
    table-layout: fixed;
    text-align: left;
    overflow: auto;
    display: table;
    word-wrap: break-word;
    word-break: break-all;
}
#wenyan table td,
#wenyan table th {
    font-size: 0.75em;
    padding: 9px 12px;
    line-height: 22px;
    color: #222;
    border: 1px solid var(--border-quote);
    vertical-align: top;
}
#wenyan table th {
    font-weight: bold;
    color: var(--title-color);
    background-color: var(--inline-code-bg);
}
#wenyan strong {
    padding: 0 2px;
    font-weight: bold;
}
#wenyan p code {
    padding: 2px 4px;
    border-radius: 0.3em;
    font-family: var(--monospace-font);
    font-size: 0.9em;
    color: var(--code-color);
    background-color: var(--inline-code-bg);
    margin: 0 2px;
}
#wenyan img {
    max-width: 100%;
    height: auto;
    margin: 0 auto;
    display: block;
}
#wenyan pre {
    border-radius: 5px;
    line-height: 2;
    margin: 1em 0.5em;
    padding: .5em;
    box-shadow: rgba(0, 0, 0, 0.55) 0px 1px 5px;
}
#wenyan pre code {
    display: block;
    overflow-x: auto;
    margin: .5em;
    padding: 0;
    font-family: var(--monospace-font);
}
#wenyan .footnote {
    color: var(--code-color);
    background-color: var(--inline-code-bg);
}
#wenyan #footnotes p {
    display: flex;
    margin: 0;
    font-size: 0.9em;
}
#wenyan .footnote-num {
    display: inline;
    width: 10%;
}
#wenyan .footnote-txt {
    display: inline;
    width: 90%;
    word-wrap: break-word;
    word-break: break-all;
}
`},Symbol.toStringTag,{value:"Module"})),z=Object.freeze(Object.defineProperty({__proto__:null,default:`/*
 *     Typora Theme - Rainbow    /    Author - thezbm
 *     https://github.com/thezbm/typora-theme-rainbow
 */

:root {
    --h-border-color: rgb(255, 191, 191);
    --h-bg-color: rgb(255, 232, 232);
    --table-border-color: rgb(255, 235, 211);
    --th-bg-color: rgb(255, 243, 228);
    --tr-bg-color: rgb(255, 249, 242);
    --code-bg-color: rgb(247, 247, 247);
    --block-shadow: 0.15em 0.15em 0.5em rgb(150, 150, 150);
}
#wenyan {
    font-family: var(--sans-serif-font);
    line-height: 1.75;
    font-size: 16px;
}
#wenyan p,
#wenyan pre {
    margin: 1em 0;
}
#wenyan h1,
#wenyan h2,
#wenyan h3,
#wenyan h4,
#wenyan h5,
#wenyan h6 {
    margin: 1.2em 0 1em;
    padding: 0px;
    font-weight: bold;
}
#wenyan h1 {
    font-size: 1.5em;
    text-align: center;
    text-shadow: 0.15em 0.15em 0.3em rgb(187, 187, 187);
}
#wenyan h2 {
    font-size: 1.3em;
    background-color: var(--h-bg-color);
    padding-left: 1em;
    padding-right: 1em;
    border-left: 0.5em solid var(--h-border-color);
    border-radius: 0.4em;
    display: inline-block;
}
#wenyan h3 {
    font-size: 1.3em;
    text-decoration: underline double var(--h-border-color);
    -webkit-text-decoration: underline double var(--h-border-color);
    text-decoration-thickness: 0.15em;
}
#wenyan h4 {
    font-size: 1.2em;
    text-decoration: underline dotted var(--h-border-color);
    -webkit-text-decoration: underline dotted var(--h-border-color);
    text-decoration-thickness: 0.2em;
}
#wenyan table {
    border-collapse: collapse;
    border: 0.25em solid var(--table-border-color);
    margin: 1.4em auto;
    max-width: 100%;
    table-layout: fixed;
    text-align: left;
    overflow: auto;
    display: table;
    word-wrap: break-word;
    word-break: break-all;
}
#wenyan table th {
    background-color: var(--th-bg-color);
}
#wenyan table th,
#wenyan table td {
    font-size: 0.75em;
    text-align: center;
    border: 0.13em dashed var(--table-border-color);
    padding: 0.5em;
    padding: 9px 12px;
    line-height: 22px;
    vertical-align: top;
}
#wenyan table tr:nth-child(even) {
    background-color: var(--tr-bg-color);
}
#wenyan blockquote {
    font-size: 0.9em;
    margin: 0 1em;
    color: rgb(102, 102, 102);
    border-left: 0.25em solid rgb(169, 202, 255);
    padding: 0.5em 1em 0.6em 1em;
}
#wenyan blockquote::before {
    display: block;
    height: 2em;
    width: 1.5em;
    content: "🌈";
    font-size: 1.2em;
}
#wenyan blockquote p {
    margin: 0;
}
#wenyan hr {
    margin-top: 2em;
    margin-bottom: 2em;
    background-color: rgb(226, 226, 226);
    height: 0.13em;
    border: 0;
}
#wenyan pre {
    line-height: 2;
    padding: .5em;
    border-radius: 0.4em;
    box-shadow: var(--block-shadow);
}
#wenyan pre code {
    display: block;
    overflow-x: auto;
    margin: .5em;
    padding: 0;
    font-family: var(--monospace-font);
}
#wenyan p code {
    font-family: var(--monospace-font);
    margin-left: 0.25em;
    margin-right: 0.25em;
    padding: 0.05em 0.3em;
    background-color: var(--code-bg-color);
    border-radius: 0.4em;
    box-shadow: 0.13em 0.13em 0.26em rgb(197, 197, 197);
    font-size: 0.9em;
}
#wenyan a {
    word-wrap: break-word;
    color: rgb(31, 117, 255);
}
#wenyan img {
    max-width: 100%;
    height: auto;
    margin: 0 auto;
    display: block;
    border-radius: 5px;
    box-shadow: var(--block-shadow);
}
#wenyan .footnote {
    color: rgb(31, 117, 255);
}
#wenyan #footnotes p {
    display: flex;
    margin: 0;
    font-size: 0.9em;
}
#wenyan .footnote-num {
    display: inline;
    width: 10%;
}
#wenyan .footnote-txt {
    display: inline;
    width: 90%;
    word-wrap: break-word;
    word-break: break-all;
}
`},Symbol.toStringTag,{value:"Module"})),_=Object.freeze(Object.defineProperty({__proto__:null,default:`#wenyan {
    font-family: var(--sans-serif-font);
    line-height: 1.75;
}
#wenyan * {
    box-sizing: border-box;
}
#wenyan h1,
#wenyan h2,
#wenyan h3,
#wenyan h4,
#wenyan h5,
#wenyan h6,
#wenyan p,
#wenyan pre {
    margin: 1em 0;
}
#wenyan h1,
#wenyan h2,
#wenyan h3,
#wenyan h4,
#wenyan h5,
#wenyan h6 {
    font-size: 17px;
    line-height: 30px;
    margin-top: 20px;
    margin-bottom: 12px;
    position: relative;
}
#wenyan h1:before,
#wenyan h2:before,
#wenyan h3:before,
#wenyan h4:before,
#wenyan h5:before,
#wenyan h6:before {
    content: "";
    display: inline-block;
    vertical-align: 1px;
    width: 10px;
    height: 26px;
    margin-right: 6px;
    background-image: url(data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIxMCIgaGVpZ2h0PSIyNiIgdmlld0JveD0iMCAwIDEwIDI2IiBmaWxsPSJub25lIj4KICA8cGF0aCBkPSJNOS41IDYuNTY2NTlMNC40OTk5NCAxOS40MzI2TDAgMTkuNDMyNkw1LjAwMDA2IDYuNTY2NTlMOS41IDYuNTY2NTlaIiBmaWxsPSIjRkY0MDNBIi8+Cjwvc3ZnPgo=);
    background-repeat: no-repeat;
    background-size: cover;
    background-position-y: 8px;
}
#wenyan ul,
#wenyan ol {
    padding-left: 1.2em;
}
#wenyan li {
    margin-left: 1.2em;
}
#wenyan img {
    max-width: 100%;
    height: auto;
    margin: 0 auto;
    display: block;
}
#wenyan table {
    margin-left: auto;
    margin-right: auto;
    border-collapse: collapse;
    table-layout: fixed;
    overflow: auto;
    border-spacing: 0;
    font-size: 1em;
    word-wrap: break-word;
    word-break: break-all;
}
#wenyan table td,
#wenyan table th {
    height: 40px;
    padding: 9px 12px;
    line-height: 22px;
    color: #222;
    min-width: 88px;
    border: 1px solid #d8d8d8;
    vertical-align: top;
}
#wenyan blockquote {
    margin: 0;
    margin-bottom: 20px;
    padding: 0 16px;
    position: relative;
    color: #999;
    text-align: justify;
}
#wenyan blockquote:before {
    content: " ";
    left: 0;
    position: absolute;
    width: 2px;
    height: 100%;
    background: #f2f2f2;
}
#wenyan p code {
    font-family: var(--monospace-font);
    color: #1e6bb8;
}
/* 代码块 */
#wenyan pre {
    border-radius: 3px;
    border: 1px solid #e8e8e8;
    line-height: 2;
    margin: 1em 0.5em;
    padding: .5em;
}
#wenyan pre code {
    font-family: var(--monospace-font);
    display: block;
    overflow-x: auto;
    margin: .5em;
    padding: 0;
}
#wenyan hr {
    width: 100%;
    height: 1px;
    background-color: #e8e8e8;
    border: none;
    margin: 20px 0;
}
/* 链接 */
#wenyan a {
    word-wrap: break-word;
    color: #0069c2;
}
/* 脚注 */
#wenyan #footnotes ul {
    font-size: 0.9em;
    margin: 0;
    padding-left: 1.2em;
}
#wenyan #footnotes li {
    margin: 0 0 0 1.2em;
    word-wrap: break-word;
    word-break: break-all;
}
#wenyan .footnote {
    color: #0069c2;
}
`},Symbol.toStringTag,{value:"Module"})),M=Object.freeze(Object.defineProperty({__proto__:null,default:`#wenyan {
    font-family: var(--sans-serif-font);
    line-height: 1.75;
    font-size: 16px;
}
#wenyan * {
    box-sizing: border-box;
}
#wenyan h1,
#wenyan h2,
#wenyan h3,
#wenyan h4,
#wenyan h5,
#wenyan h6,
#wenyan p,
#wenyan pre {
    margin: 1em 0;
}
#wenyan h1,
#wenyan h2 {
    clear: left;
    font-size: 1.2em;
    font-weight: 600;
    line-height: 1.5;
    margin-bottom: 1.16667em;
    margin-top: 2.33333em;
}
#wenyan h3,
#wenyan h4,
#wenyan h5,
#wenyan h6 {
    clear: left;
    font-size: 1.1em;
    font-weight: 600;
    line-height: 1.5;
    margin-bottom: 1.27273em;
    margin-top: 1.90909em;
}
#wenyan ul,
#wenyan ol {
    padding-left: 1.2em;
}
#wenyan li {
    margin-left: 1.2em;
}
#wenyan img {
    max-width: 100%;
    height: auto;
    margin: 0 auto;
    display: block;
}
#wenyan table {
    border-collapse: collapse;
    font-size: 15px;
    margin: 1.4em auto;
    max-width: 100%;
    table-layout: fixed;
    text-align: left;
    width: 100%;
    word-wrap: break-word;
    word-break: break-all;
}
#wenyan table th {
    background: #ebeced;
    color: #191b1f;
    font-weight: 500;
}
#wenyan table td,
#wenyan table th {
    border: 1px solid #c4c7ce;
    height: 24px;
    line-height: 24px;
    padding: 3px 12px;
}
#wenyan blockquote {
    border-left: 3px solid #c4c7ce;
    margin: 1.5em 0;
    padding: 0 0 1em 1em;
    color: #535861;
}
#wenyan code {
    margin: 0px 2px;
    padding: 3px 4px;
    border-radius: 3px;
    font-family: var(--monospace-font);
    background-color: rgb(246, 246, 246);
}
#wenyan pre {
    word-wrap: normal;
    background: #f8f8fa;
    border-radius: 4px;
    line-height: 2;
    margin: 1em 0.5em;
    padding: .5em;
    white-space: pre;
    word-break: normal;
}
#wenyan pre code {
    display: block;
    overflow-x: auto;
    margin: .5em;
    padding: 0;
}
#wenyan hr {
    border: none;
    border-top: 1px solid #c4c7ce;
    margin: 2em auto;
    max-width: 100%;
    width: 240px;
}
/* 链接 */
#wenyan a {
    word-wrap: break-word;
    color: #0069c2;
}
/* 脚注 */
#wenyan #footnotes ul {
    font-size: 0.9em;
    margin: 0;
    padding-left: 1.2em;
}
#wenyan #footnotes li {
    margin: 0 0 0 1.2em;
    word-wrap: break-word;
    word-break: break-all;
}
#wenyan .footnote {
    color: #0069c2;
}
`},Symbol.toStringTag,{value:"Module"})),T=Object.freeze(Object.defineProperty({__proto__:null,default:"pre{background:#282c34}pre code.hljs{display:block;overflow-x:auto;padding:1em}code.hljs{padding:3px 5px}.hljs{color:#abb2bf;background:#282c34}.hljs-comment,.hljs-quote{color:#5c6370;font-style:italic}.hljs-doctag,.hljs-formula,.hljs-keyword{color:#c678dd}.hljs-deletion,.hljs-name,.hljs-section,.hljs-selector-tag,.hljs-subst{color:#e06c75}.hljs-literal{color:#56b6c2}.hljs-addition,.hljs-attribute,.hljs-meta .hljs-string,.hljs-regexp,.hljs-string{color:#98c379}.hljs-attr,.hljs-number,.hljs-selector-attr,.hljs-selector-class,.hljs-selector-pseudo,.hljs-template-variable,.hljs-type,.hljs-variable{color:#d19a66}.hljs-bullet,.hljs-link,.hljs-meta,.hljs-selector-id,.hljs-symbol,.hljs-title{color:#61aeee}.hljs-built_in,.hljs-class .hljs-title,.hljs-title.class_{color:#e6c07b}.hljs-emphasis{font-style:italic}.hljs-strong{font-weight:700}.hljs-link{text-decoration:underline}"},Symbol.toStringTag,{value:"Module"})),O=Object.freeze(Object.defineProperty({__proto__:null,default:"pre{background:#fafafa}pre code.hljs{display:block;overflow-x:auto;padding:1em}code.hljs{padding:3px 5px}.hljs{color:#383a42;background:#fafafa}.hljs-comment,.hljs-quote{color:#a0a1a7;font-style:italic}.hljs-doctag,.hljs-formula,.hljs-keyword{color:#a626a4}.hljs-deletion,.hljs-name,.hljs-section,.hljs-selector-tag,.hljs-subst{color:#e45649}.hljs-literal{color:#0184bb}.hljs-addition,.hljs-attribute,.hljs-meta .hljs-string,.hljs-regexp,.hljs-string{color:#50a14f}.hljs-attr,.hljs-number,.hljs-selector-attr,.hljs-selector-class,.hljs-selector-pseudo,.hljs-template-variable,.hljs-type,.hljs-variable{color:#986801}.hljs-bullet,.hljs-link,.hljs-meta,.hljs-selector-id,.hljs-symbol,.hljs-title{color:#4078f2}.hljs-built_in,.hljs-class .hljs-title,.hljs-title.class_{color:#c18401}.hljs-emphasis{font-style:italic}.hljs-strong{font-weight:700}.hljs-link{text-decoration:underline}"},Symbol.toStringTag,{value:"Module"})),S=Object.freeze(Object.defineProperty({__proto__:null,default:`pre{background:#282936}
/*!
  Theme: Dracula
  Author: Mike Barkmin (http://github.com/mikebarkmin) based on Dracula Theme (http://github.com/dracula)
  License: ~ MIT (or more permissive) [via base16-schemes-source]
  Maintainer: @highlightjs/core-team
  Version: 2021.09.0
*/pre code.hljs{display:block;overflow-x:auto;padding:1em}code.hljs{padding:3px 5px}.hljs{color:#e9e9f4;background:#282936}.hljs ::selection,.hljs::selection{background-color:#4d4f68;color:#e9e9f4}.hljs-comment{color:#626483}.hljs-tag{color:#62d6e8}.hljs-operator,.hljs-punctuation,.hljs-subst{color:#e9e9f4}.hljs-operator{opacity:.7}.hljs-bullet,.hljs-deletion,.hljs-name,.hljs-selector-tag,.hljs-template-variable,.hljs-variable{color:#ea51b2}.hljs-attr,.hljs-link,.hljs-literal,.hljs-number,.hljs-symbol,.hljs-variable.constant_{color:#b45bcf}.hljs-class .hljs-title,.hljs-title,.hljs-title.class_{color:#00f769}.hljs-strong{font-weight:700;color:#00f769}.hljs-addition,.hljs-code,.hljs-string,.hljs-title.class_.inherited__{color:#ebff87}.hljs-built_in,.hljs-doctag,.hljs-keyword.hljs-atrule,.hljs-quote,.hljs-regexp{color:#a1efe4}.hljs-attribute,.hljs-function .hljs-title,.hljs-section,.hljs-title.function_,.ruby .hljs-property{color:#62d6e8}.diff .hljs-meta,.hljs-keyword,.hljs-template-tag,.hljs-type{color:#b45bcf}.hljs-emphasis{color:#b45bcf;font-style:italic}.hljs-meta,.hljs-meta .hljs-keyword,.hljs-meta .hljs-string{color:#00f769}.hljs-meta .hljs-keyword,.hljs-meta-keyword{font-weight:700}`},Symbol.toStringTag,{value:"Module"})),I=Object.freeze(Object.defineProperty({__proto__:null,default:`pre{background:#0d1117}pre code.hljs{display:block;overflow-x:auto;padding:1em}code.hljs{padding:3px 5px}/*!
  Theme: GitHub Dark
  Description: Dark theme as seen on github.com
  Author: github.com
  Maintainer: @Hirse
  Updated: 2021-05-15

  Outdated base version: https://github.com/primer/github-syntax-dark
  Current colors taken from GitHub's CSS
*/.hljs{color:#c9d1d9;background:#0d1117}.hljs-doctag,.hljs-keyword,.hljs-meta .hljs-keyword,.hljs-template-tag,.hljs-template-variable,.hljs-type,.hljs-variable.language_{color:#ff7b72}.hljs-title,.hljs-title.class_,.hljs-title.class_.inherited__,.hljs-title.function_{color:#d2a8ff}.hljs-attr,.hljs-attribute,.hljs-literal,.hljs-meta,.hljs-number,.hljs-operator,.hljs-selector-attr,.hljs-selector-class,.hljs-selector-id,.hljs-variable{color:#79c0ff}.hljs-meta .hljs-string,.hljs-regexp,.hljs-string{color:#a5d6ff}.hljs-built_in,.hljs-symbol{color:#ffa657}.hljs-code,.hljs-comment,.hljs-formula{color:#8b949e}.hljs-name,.hljs-quote,.hljs-selector-pseudo,.hljs-selector-tag{color:#7ee787}.hljs-subst{color:#c9d1d9}.hljs-section{color:#1f6feb;font-weight:700}.hljs-bullet{color:#f2cc60}.hljs-emphasis{color:#c9d1d9;font-style:italic}.hljs-strong{color:#c9d1d9;font-weight:700}.hljs-addition{color:#aff5b4;background-color:#033a16}.hljs-deletion{color:#ffdcd7;background-color:#67060c}`},Symbol.toStringTag,{value:"Module"})),P=Object.freeze(Object.defineProperty({__proto__:null,default:`pre{background:#fff}pre code.hljs{display:block;overflow-x:auto;padding:1em}code.hljs{padding:3px 5px}/*!
  Theme: GitHub
  Description: Light theme as seen on github.com
  Author: github.com
  Maintainer: @Hirse
  Updated: 2021-05-15

  Outdated base version: https://github.com/primer/github-syntax-light
  Current colors taken from GitHub's CSS
*/.hljs{color:#24292e;background:#fff}.hljs-doctag,.hljs-keyword,.hljs-meta .hljs-keyword,.hljs-template-tag,.hljs-template-variable,.hljs-type,.hljs-variable.language_{color:#d73a49}.hljs-title,.hljs-title.class_,.hljs-title.class_.inherited__,.hljs-title.function_{color:#6f42c1}.hljs-attr,.hljs-attribute,.hljs-literal,.hljs-meta,.hljs-number,.hljs-operator,.hljs-selector-attr,.hljs-selector-class,.hljs-selector-id,.hljs-variable{color:#005cc5}.hljs-meta .hljs-string,.hljs-regexp,.hljs-string{color:#032f62}.hljs-built_in,.hljs-symbol{color:#e36209}.hljs-code,.hljs-comment,.hljs-formula{color:#6a737d}.hljs-name,.hljs-quote,.hljs-selector-pseudo,.hljs-selector-tag{color:#22863a}.hljs-subst{color:#24292e}.hljs-section{color:#005cc5;font-weight:700}.hljs-bullet{color:#735c0f}.hljs-emphasis{color:#24292e;font-style:italic}.hljs-strong{color:#24292e;font-weight:700}.hljs-addition{color:#22863a;background-color:#f0fff4}.hljs-deletion{color:#b31d28;background-color:#ffeef0}
`},Symbol.toStringTag,{value:"Module"})),D=Object.freeze(Object.defineProperty({__proto__:null,default:"pre{background:#272822}pre code.hljs{display:block;overflow-x:auto;padding:1em}code.hljs{padding:3px 5px}.hljs{background:#272822;color:#ddd}.hljs-keyword,.hljs-literal,.hljs-name,.hljs-number,.hljs-selector-tag,.hljs-strong,.hljs-tag{color:#f92672}.hljs-code{color:#66d9ef}.hljs-attr,.hljs-attribute,.hljs-link,.hljs-regexp,.hljs-symbol{color:#bf79db}.hljs-addition,.hljs-built_in,.hljs-bullet,.hljs-emphasis,.hljs-section,.hljs-selector-attr,.hljs-selector-pseudo,.hljs-string,.hljs-subst,.hljs-template-tag,.hljs-template-variable,.hljs-title,.hljs-type,.hljs-variable{color:#a6e22e}.hljs-class .hljs-title,.hljs-title.class_{color:#fff}.hljs-comment,.hljs-deletion,.hljs-meta,.hljs-quote{color:#75715e}.hljs-doctag,.hljs-keyword,.hljs-literal,.hljs-section,.hljs-selector-id,.hljs-selector-tag,.hljs-title,.hljs-type{font-weight:700}"},Symbol.toStringTag,{value:"Module"})),N=Object.freeze(Object.defineProperty({__proto__:null,default:`pre{background:#002b36}
/*!
  Theme: Solarized Dark
  Author: Ethan Schoonover (modified by aramisgithub)
  License: ~ MIT (or more permissive) [via base16-schemes-source]
  Maintainer: @highlightjs/core-team
  Version: 2021.09.0
*/pre code.hljs{display:block;overflow-x:auto;padding:1em}code.hljs{padding:3px 5px}.hljs{color:#93a1a1;background:#002b36}.hljs ::selection,.hljs::selection{background-color:#586e75;color:#93a1a1}.hljs-comment{color:#657b83}.hljs-tag{color:#839496}.hljs-operator,.hljs-punctuation,.hljs-subst{color:#93a1a1}.hljs-operator{opacity:.7}.hljs-bullet,.hljs-deletion,.hljs-name,.hljs-selector-tag,.hljs-template-variable,.hljs-variable{color:#dc322f}.hljs-attr,.hljs-link,.hljs-literal,.hljs-number,.hljs-symbol,.hljs-variable.constant_{color:#cb4b16}.hljs-class .hljs-title,.hljs-title,.hljs-title.class_{color:#b58900}.hljs-strong{font-weight:700;color:#b58900}.hljs-addition,.hljs-code,.hljs-string,.hljs-title.class_.inherited__{color:#859900}.hljs-built_in,.hljs-doctag,.hljs-keyword.hljs-atrule,.hljs-quote,.hljs-regexp{color:#2aa198}.hljs-attribute,.hljs-function .hljs-title,.hljs-section,.hljs-title.function_,.ruby .hljs-property{color:#268bd2}.diff .hljs-meta,.hljs-keyword,.hljs-template-tag,.hljs-type{color:#6c71c4}.hljs-emphasis{color:#6c71c4;font-style:italic}.hljs-meta,.hljs-meta .hljs-keyword,.hljs-meta .hljs-string{color:#d33682}.hljs-meta .hljs-keyword,.hljs-meta-keyword{font-weight:700}`},Symbol.toStringTag,{value:"Module"})),A=Object.freeze(Object.defineProperty({__proto__:null,default:`pre{background:#fdf6e3}
/*!
  Theme: Solarized Light
  Author: Ethan Schoonover (modified by aramisgithub)
  License: ~ MIT (or more permissive) [via base16-schemes-source]
  Maintainer: @highlightjs/core-team
  Version: 2021.09.0
*/pre code.hljs{display:block;overflow-x:auto;padding:1em}code.hljs{padding:3px 5px}.hljs{color:#586e75;background:#fdf6e3}.hljs ::selection,.hljs::selection{background-color:#93a1a1;color:#586e75}.hljs-comment{color:#839496}.hljs-tag{color:#657b83}.hljs-operator,.hljs-punctuation,.hljs-subst{color:#586e75}.hljs-operator{opacity:.7}.hljs-bullet,.hljs-deletion,.hljs-name,.hljs-selector-tag,.hljs-template-variable,.hljs-variable{color:#dc322f}.hljs-attr,.hljs-link,.hljs-literal,.hljs-number,.hljs-symbol,.hljs-variable.constant_{color:#cb4b16}.hljs-class .hljs-title,.hljs-title,.hljs-title.class_{color:#b58900}.hljs-strong{font-weight:700;color:#b58900}.hljs-addition,.hljs-code,.hljs-string,.hljs-title.class_.inherited__{color:#859900}.hljs-built_in,.hljs-doctag,.hljs-keyword.hljs-atrule,.hljs-quote,.hljs-regexp{color:#2aa198}.hljs-attribute,.hljs-function .hljs-title,.hljs-section,.hljs-title.function_,.ruby .hljs-property{color:#268bd2}.diff .hljs-meta,.hljs-keyword,.hljs-template-tag,.hljs-type{color:#6c71c4}.hljs-emphasis{color:#6c71c4;font-style:italic}.hljs-meta,.hljs-meta .hljs-keyword,.hljs-meta .hljs-string{color:#d33682}.hljs-meta .hljs-keyword,.hljs-meta-keyword{font-weight:700}`},Symbol.toStringTag,{value:"Module"})),L=Object.freeze(Object.defineProperty({__proto__:null,default:"pre{background:#fff}pre code.hljs{display:block;overflow-x:auto;padding:1em}code.hljs{padding:3px 5px}.hljs{background:#fff;color:#000}.xml .hljs-meta{color:silver}.hljs-comment,.hljs-quote{color:#007400}.hljs-attribute,.hljs-keyword,.hljs-literal,.hljs-name,.hljs-selector-tag,.hljs-tag{color:#aa0d91}.hljs-template-variable,.hljs-variable{color:#3f6e74}.hljs-code,.hljs-meta .hljs-string,.hljs-string{color:#c41a16}.hljs-link,.hljs-regexp{color:#0e0eff}.hljs-bullet,.hljs-number,.hljs-symbol,.hljs-title{color:#1c00cf}.hljs-meta,.hljs-section{color:#643820}.hljs-built_in,.hljs-class .hljs-title,.hljs-params,.hljs-title.class_,.hljs-type{color:#5c2699}.hljs-attr{color:#836c28}.hljs-subst{color:#000}.hljs-formula{background-color:#eee;font-style:italic}.hljs-addition{background-color:#baeeba}.hljs-deletion{background-color:#ffc8bd}.hljs-selector-class,.hljs-selector-id{color:#9b703f}.hljs-doctag,.hljs-strong{font-weight:700}.hljs-emphasis{font-style:italic}"},Symbol.toStringTag,{value:"Module"}));return e.getAllHlThemes=g,e.getAllThemes=h,e.hlThemes=a,e.otherThemes=c,e.themes=t,Object.defineProperty(e,Symbol.toStringTag,{value:"Module"}),e})({});
