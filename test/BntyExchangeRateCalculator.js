import expectThrow from './helpers/expectThrow';
import { ONE_DAY_SECONDS, ONE_HOUR_SECONDS, withinPercentage } from './helpers/util';

const BntyExchangeRateCalculator = artifacts.require('BntyExchangeRateCalculator');
const MockBntyExchangeRateCalculator = artifacts.require('MockBntyExchangeRateCalculator');

const CROWDSALE_PRICE = 16500;
const PRESALE_PRICE = 13200;

const CONVERSION_TEST_CASES = [
  {
    ethPriceUSD: 355,
    bntyMicrodollarPrice: PRESALE_PRICE
  },
  {
    ethPriceUSD: 355,
    bntyMicrodollarPrice: CROWDSALE_PRICE
  },
  {
    ethPriceUSD: 460,
    bntyMicrodollarPrice: PRESALE_PRICE
  },
  {
    ethPriceUSD: 460,
    bntyMicrodollarPrice: CROWDSALE_PRICE
  },
  {
    ethPriceUSD: 750,
    bntyMicrodollarPrice: PRESALE_PRICE
  },
  {
    ethPriceUSD: 750,
    bntyMicrodollarPrice: CROWDSALE_PRICE
  }
];

contract('BntyExchangeRateCalculator', function (accounts) {
  CONVERSION_TEST_CASES.forEach(
    ({ ethPriceUSD, bntyMicrodollarPrice }) => {
      describe(`ETH Price: $${ethPriceUSD}, USD/BNTY: $${bntyMicrodollarPrice * Math.pow(10, -6)}`, async () => {
        let calculator;
        before(async () => {
          calculator = await BntyExchangeRateCalculator.new(bntyMicrodollarPrice, ethPriceUSD, 0);
        });

        describe('#weiToBnty', () => {
          it(
            `calculates BNTY per WEI correctly`,
            async () => {
              // for 0 wei to 10 eth
              for (
                let testWeiAmt = 0;
                testWeiAmt < Math.pow(10, 19);
                testWeiAmt = testWeiAmt === 0 ? 1 : testWeiAmt * 2
              ) {
                const rewardFor = await calculator.weiToBnty(testWeiAmt);

                const bntyUsdPrice = bntyMicrodollarPrice * Math.pow(10, -6);
                withinPercentage(rewardFor, (ethPriceUSD * testWeiAmt / bntyUsdPrice));
              }
            }
          );
        });

        describe('#usdToWei', async () => {
          it(
            `calculates WEI per USD correctly`, async () => {
              for (let testUsdAmt = 0; testUsdAmt < 1500000; testUsdAmt = testUsdAmt === 0 ? 1 : testUsdAmt * 2) {
                const usdToWei = await calculator.usdToWei(testUsdAmt);

                withinPercentage(usdToWei, (testUsdAmt / ethPriceUSD) * Math.pow(10, 18));
              }
            }
          );
        });
      });
    }
  );

  describe('#setUSDEtherPrice', function () {
    let calc;
    const TEST_LOCKED_TIME = 1513346400;

    beforeEach(async () => {
      calc = await MockBntyExchangeRateCalculator.new(16500, 355, 1513346400);
    });

    it('can be changed one day before the lock time', async () => {
      await calc.setTime(TEST_LOCKED_TIME - ONE_DAY_SECONDS);

      await calc.setUSDEtherPrice(460);
    });

    it('can be changed one hour before lock time', async () => {
      await calc.setTime(TEST_LOCKED_TIME - ONE_HOUR_SECONDS);

      await calc.setUSDEtherPrice(460);
    });

    it('can be changed one second before lock time', async () => {
      await calc.setTime(TEST_LOCKED_TIME - 1);

      await calc.setUSDEtherPrice(460);
    });

    it('cannot be changed at lock time', async () => {
      await calc.setTime(TEST_LOCKED_TIME);

      await expectThrow(calc.setUSDEtherPrice(460));
    });

    it('cannot be changed after lock time', async () => {
      await calc.setTime(TEST_LOCKED_TIME + 1);

      await expectThrow(calc.setUSDEtherPrice(460));
    });

    it('cannot be changed one day after lock time', async () => {
      await calc.setTime(TEST_LOCKED_TIME + ONE_DAY_SECONDS);

      await expectThrow(calc.setUSDEtherPrice(460));
    });
  });
});
