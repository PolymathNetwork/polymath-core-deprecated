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

module.exports = {
    ensureException:ensureException,
    timeDifference:timeDifference
}


