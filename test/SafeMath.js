import expectRevert from './helpers/expectRevert';
const SafeMathMock = artifacts.require('./helpers/mockContracts/SafeMathMock.sol');

contract('SafeMath', (accounts) => {
  let safeMath;

  beforeEach(async () => {
    safeMath = await SafeMathMock.new();
  });

  describe('mul', async () => {
    [[5678, 1234],
     [2, 0],
     [575689, 123]
    ].forEach((pair) => {
      it(`multiplies ${pair[0]} and ${pair[1]} correctly`, async () => {
        let a = pair[0];
        let b = pair[1];
        await safeMath.multiply(a, b);
        let result = await safeMath.result();
        assert.equal(result, a * b);
      });
    });

    it('should throw an error on multiplication overflow', async () => {
      let a = 115792089237316195423570985008687907853269984665640564039457584007913129639933;
      let b = 2;

      await expectRevert(safeMath.multiply(a, b));
    });
  });

  describe('add', async () => {
    [[5678, 1234],
     [2, 0],
     [123, 575689]
    ].forEach((pair) => {
      it(`adds ${pair[0]} and ${pair[1]} correctly`, async () => {
        let a = pair[0];
        let b = pair[1];
        await safeMath.add(a, b);
        let result = await safeMath.result();

        assert.equal(result, a + b);
      });
    });

    it('should throw an error on addition overflow', async () => {
      let a = 115792089237316195423570985008687907853269984665640564039457584007913129639935;
      let b = 1;

      await expectRevert(safeMath.add(a, b));
    });
  });

  describe('sub', async () => {
    [[5678, 1234],
     [2, 0],
     [575689, 123]
    ].forEach((pair) => {
      it(`subtracts ${pair[0]} and ${pair[1]} correctly`, async () => {
        let a = pair[0];
        let b = pair[1];
        await safeMath.subtract(a, b);
        let result = await safeMath.result();

        assert.equal(result, a - b);
      });
    });

    it('should throw an error if subtraction result would be negative', async () => {
      let a = 1234;
      let b = 5678;

      await expectRevert(safeMath.subtract(a, b));
    });
  });

  describe('div', () => {
    [[5678, 1234],
     [2, 1],
     [123, 575689]
    ].forEach((pair) => {
      it(`divides ${pair[0]} and ${pair[1]} correctly`, async () => {
        let a = pair[0];
        let b = pair[1];
        await safeMath.divide(a, b);
        let result = await safeMath.result();

        assert.equal(result, Math.floor(a / b));
      });
    });

    it('should throw an error on division by 0', async () => {
      let a = 100;
      let b = 0;

      await expectRevert(safeMath.divide(a, b));
    });
  });

  describe('max64', () => {
    [[5678, 1234],
     [2, 1],
     [123, 575689]
    ].forEach((pair) => {
      it(`get the max64 of ${pair[0]} and ${pair[1]} correctly`, async () => {
        let a = pair[0];
        let b = pair[1];
        await safeMath.max64(a, b);
        let result = await safeMath.result();

        assert.equal(result, Math.max(a, b));
      });
    });
  });

  describe('min64', () => {
    [[5678, 1234],
     [2, 1],
     [123, 575689]
    ].forEach((pair) => {
      it(`get the min64 of ${pair[0]} and ${pair[1]} correctly`, async () => {
        let a = pair[0];
        let b = pair[1];
        await safeMath.min64(a, b);
        let result = await safeMath.result();

        assert.equal(result, Math.min(a, b));
      });
    });
  });

  describe('max256', () => {
    [[5678, 1234],
     [2, 1],
     [123, 575689]
    ].forEach((pair) => {
      it(`get the max256 of ${pair[0]} and ${pair[1]} correctly`, async () => {
        let a = pair[0];
        let b = pair[1];
        await safeMath.max256(a, b);
        let result = await safeMath.result();

        assert.equal(result, Math.max(a, b));
      });
    });
  });

  describe('min256', () => {
    [[5678, 1234],
     [2, 1],
     [123, 575689]
    ].forEach((pair) => {
      it(`get the min256 of ${pair[0]} and ${pair[1]} correctly`, async () => {
        let a = pair[0];
        let b = pair[1];
        await safeMath.min256(a, b);
        let result = await safeMath.result();

        assert.equal(result, Math.min(a, b));
      });
    });
  });
});
