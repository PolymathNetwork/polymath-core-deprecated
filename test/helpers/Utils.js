/* global assert */

function isException(error) {
    let strError = error.toString();
    return strError.includes('invalid opcode') || strError.includes('invalid JUMP') || strError.includes('revert');
}

function ensureException(error) {
    assert(isException(error), error.toString());
}

async function timeDifference(timestamp1,timestamp2) {
    var difference = timestamp1 - timestamp2;
    return difference;
}

function convertHex(hexx) {
    var hex = hexx.toString(); //force conversion
    var str = '';
    for (var i = 0; i < hex.length; i += 2) {
      let char = String.fromCharCode(parseInt(hex.substr(i, 2), 16));
      if (char != '\u0000') str += char;
    }
    return str;
  }

module.exports = {
    ensureException:ensureException,
    timeDifference:timeDifference,
    convertHex:convertHex
}


