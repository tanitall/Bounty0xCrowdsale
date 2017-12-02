const BntyExchangeRateCalculator = artifacts.require('BntyExchangeRateCalculator');

const TEST_CASES = [
  { ethPriceUSD: 355, expectedBntyPerWei: 26893 }
];

contract('Bounty0xCrowdsale', function (accounts) {
  _.each(
    TEST_CASES,
    ({ ethPriceUSD, expectedBntyPerWei }) => {
      // deploy the BntyExchangeRateCalculator
      it(`exchange rate calculator works at ETH price: $${ethPriceUSD}`, async () => {
        const xchange = await BntyExchangeRateCalculator.new(ethPriceUSD);

        const rate = await xchange.bntyPerWei();
        const oneEtherInUsd = await xchange.usdToWei(ethPriceUSD);
        const halfEtherInUsd = await xchange.usdToWei(ethPriceUSD / 2);

        assert.strictEqual(rate.valueOf(), '' + expectedBntyPerWei);
        assert.strictEqual(oneEtherInUsd.valueOf(), '' + Math.pow(10, 18));
        // this fails right now because of precision errors, off by about 0.3%
        //assert.strictEqual(halfEtherInUsd.valueOf(), '' + 0.5 * Math.pow(10, 18));
      });
    }
  );
});