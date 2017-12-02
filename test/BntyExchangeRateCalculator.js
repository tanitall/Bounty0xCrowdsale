const BntyExchangeRateCalculator = artifacts.require('BntyExchangeRateCalculator');

const CROWDSALE_PRICE = 16500;
const PRESALE_PRICE = 13200;

const TEST_CASES = [
  {
    ethPriceUSD: 355,
    bntyMicrocentPrice: PRESALE_PRICE,
    ethAmt: 1,
    expectedBnty: 355 / 0.0132
  },
  {
    ethPriceUSD: 460,
    bntyMicrocentPrice: CROWDSALE_PRICE,
    ethAmt: 3.15,
    expectedBnty: (460 / 0.0165) * 3.15
  },
];

function withinPercentage(actual, expected, percentage = 0.1) {
  if (expected === 0) {
    if (actual.valueOf() === '0') {
      return;
    } else {
      throw new Error('division by 0');
    }
  }

  const percent = actual.sub(String(expected)).abs().div(String(expected)).mul(100);

  assert.strictEqual(
    percent.lessThan(percentage),
    true
  );
}

contract('BntyExchangeRateCalculator', function (accounts) {
  _.each(
    TEST_CASES,
    ({ ethPriceUSD, bntyMicrocentPrice, ethAmt, expectedBnty }) => {
      describe(`ETH Price: $${ethPriceUSD}, USD/BNTY: ${bntyMicrocentPrice * Math.pow(10, -6)}`, async () => {
        let calculator;
        before(async () => {
          calculator = await BntyExchangeRateCalculator.new(bntyMicrocentPrice, ethPriceUSD);
        });

        it(
          `calculates BNTY rewards correctly`,
          async () => {
            const rewardFor = await calculator.weiToBnty(ethAmt * Math.pow(10, 18));

            withinPercentage(rewardFor, expectedBnty * Math.pow(10, 18));
          }
        );

        describe('#usdToWei', async () => {

          for (let testUsdAmt = 0; testUsdAmt < 1500000; testUsdAmt = testUsdAmt === 0 ? 50 : testUsdAmt * 2) {
            it(
              `calculates WEI per USD correctly for $${testUsdAmt}`, async () => {
                const usdToWei = await calculator.usdToWei(testUsdAmt);

                withinPercentage(usdToWei, (testUsdAmt / ethPriceUSD) * Math.pow(10, 18));
              }
            );
          }

        });
      });
    }
  );
});