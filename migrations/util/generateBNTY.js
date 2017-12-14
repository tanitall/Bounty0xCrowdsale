
// helper function to give bounty, has some checks around correct balances
module.exports = async (bounty0xToken, contractInstance, amount) => {
  const amtHas = await bounty0xToken.balanceOf(contractInstance.address);

  if (amtHas.valueOf() !== '0') {
    throw new Error('unexpected prior balance!');
  } else {
    await bounty0xToken.generateTokens(contractInstance.address, amount * Math.pow(10, 18));
  }

  // check the balance is as expected, trying 10 times
  for (let i = 0; i < 10; i++) {
    const newBalance = await bounty0xToken.balanceOf(contractInstance.address);

    if (newBalance.valueOf() === amtHas.plus(String(amount * Math.pow(10, 18))).valueOf()) {
      break;
    }

    if (i === 9) {
      throw new Error(`unexpected new balance! ${newBalance}`);
    }

    await sleep(1000);
  }
};