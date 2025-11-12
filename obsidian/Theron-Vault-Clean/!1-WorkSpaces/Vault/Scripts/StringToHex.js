module.exports = start;
let variables = {}; 

const FILE_NUMBER_REGEX = new RegExp(/([0-9]*)\.md$/);

const DATE_REGEX = new RegExp(/{{DATE}}|{{DATE:([^}\n\r]*)}}/);
const NAME_VALUE_REGEX = new RegExp(/{{NAME}}|{{VALUE}}/);
const VARIABLE_REGEX = new RegExp(/{{VALUE:([^\n\r}]*)}}/);
const DATE_VARIABLE_REGEX = new RegExp(/{{VDATE:([^\n\r},]*),\s*([^\n\r},]*)}}/);
const LINK_TO_CURRENT_FILE_REGEX = new RegExp(/{{LINKCURRENT}}/);

const MARKDOWN_FILE_EXTENSION_REGEX = new RegExp(/\.md$/);
const endsWithMd = (str) => MARKDOWN_FILE_EXTENSION_REGEX.test(str);

const clearGlobalVariables = () => { variables = {}; };

const error = (msg) => {
    errMsg = `QuickAdd: ${msg}`;
    console.log(errMsg);
    new Notice(errMsg, 5000);
    return new Error(errMsg);
};

const warn = (msg) => {
    console.log(`QuickAdd: ${msg}`);
    return null;
};

async function RequestStringToHex(hexStr) {
    if (!hexStr) throw error("no string provided.");
    
    const hex = await getHex(hexStr);
    if (!hex) return;

    if (hex.captureTo && typeof hex.captureTo === "string") {
        await doQuickCapture(hex);
    } else if (hex.path && typeof hex)
    } else {
        throw error(`invalid choice: ${choice.option || choice}`);
    }
}

async function getSelection(hextStr) {
    const hex = await 
}

async function getSelection() {
    let response = 
    return response;
}

async function main() {
	await getSelection();
}

main();