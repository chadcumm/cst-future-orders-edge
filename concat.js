const fs = require("fs-extra");
const concat = require("concat");

(async function() {
    const files = [
        "./dist/cst-future-orders-edge/runtime.js",
        "./dist/cst-future-orders-edge/main.js",
        "./dist/cst-future-orders-edge/polyfills.js"
    ];
    await concat(files, "./dist/cst-future-orders-edge/cst-future-orders-edge.js");

})();