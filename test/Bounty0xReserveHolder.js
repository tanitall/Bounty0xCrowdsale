const Bounty0xToken = artifacts.require('Bounty0xToken');
const Bounty0xReserveHolder = artifacts.require('Bounty0xReserveHolder');

contract('Bounty0xReserveHolder', (accounts) => {
  let token;
  let bounty0xReserveHolder;

  before('get the deployed bounty0x token', async () => {
    token = await Bounty0xToken.deployed();
    bounty0xReserveHolder = await Bounty0xReserveHolder.deployed();
  });

  it('should be deployed', async () => {
    assert.strictEqual(typeof bounty0xReserveHolder.address, 'string');
  });

  it('should have a balance of 225.15M', async () => {
    const balance = await token.balanceOf(bounty0xReserveHolder.address);
    assert.strictEqual(balance.valueOf(), '2.2515e+26');
  });
});