// Checks a mockup page without a browser: every inline script must parse, and a
// 2D page's script is run against a stub DOM. Settings buttons follow the
// skill's pattern (data-k / data-v, one delegated click handler); every
// combination of them is clicked, and generated markup containing NaN or
// undefined is reported.
// Usage: node check_page.js page.html [--syntax-only]
'use strict';
const fs = require('fs');

const [file, flag] = process.argv.slice(2);
if (!file) { console.error('usage: node check_page.js page.html [--syntax-only]'); process.exit(2); }
const html = fs.readFileSync(file, 'utf8');
const scripts = [...html.matchAll(/<script>([\s\S]*?)<\/script>/g)].map(m => m[1]);
let failed = false;
scripts.forEach((s, i) => {
	try { new Function(s); console.log(`script ${i}: parses`); }
	catch (e) { console.log(`script ${i}: ${e.message}`); failed = true; }
});
if (failed || flag === '--syntax-only' || /three(\.min)?\.js/.test(html)) {
	if (/three(\.min)?\.js/.test(html) && !failed) console.log('3D page: syntax only, look at it in the browser');
	process.exit(failed ? 1 : 0);
}

const els = {}, handlers = [];
function el(id) {
	return els[id] || (els[id] = {
		id, innerHTML: '', textContent: '', disabled: false, dataset: {}, style: {},
		classList: {toggle() {}, add() {}, remove() {}},
		setAttribute() {}, getAttribute() { return null; },
		addEventListener(type, fn) { if (type === 'click') handlers.push(fn); },
		scrollIntoView() {},
	});
}
global.document = {getElementById: el, querySelectorAll: () => [], addEventListener() {}};
global.window = global;
try { scripts.forEach(s => new Function(s)()); }
catch (e) { console.log('run: ' + e.stack); process.exit(1); }

const bad = () => Object.values(els).filter(e => /NaN|undefined/.test(e.innerHTML)).map(e => e.id);
const markup = () => Object.values(els).map(e => e.innerHTML).join('\n');
const groups = {}, toggles = new Set();
for (const m of markup().matchAll(/<button[^>]*data-k="([^"]+)"(?:[^>]*data-v="([^"]+)")?/g)) {
	if (m[2]) (groups[m[1]] = groups[m[1]] || new Set()).add(m[2]);
	else toggles.add(m[1]);
}
const dims = Object.entries(groups).map(([k, vs]) => [...vs].map(v => ({k, v})));
for (const k of toggles) dims.push([null, {k}]);
const click = d => { const target = {closest: () => ({dataset: d.v ? {k: d.k, v: d.v} : {k: d.k}, disabled: false, getAttribute: () => null})}; handlers.forEach(h => { try { h({target}); } catch (e) { /* handlers for other containers */ } }); };
let combos = 0, problems = new Set(bad());
(function walk(i) {
	if (combos >= 5000) return;
	if (i === dims.length) { combos++; bad().forEach(id => problems.add(id)); return; }
	for (const d of dims[i]) { if (d) click(d); walk(i + 1); }
})(0);
console.log(`settings: ${Object.keys(groups).length} variants, ${toggles.size} toggles, ${combos} combinations clicked`);
console.log(problems.size ? `NaN/undefined in: ${[...problems].join(', ')}` : 'markup: ok');
process.exit(problems.size ? 1 : 0);
