const Bounty0xToken = artifacts.require('Bounty0xToken.sol');

contract('Bounty0xToken', () => {
  let bounty0xtoken;

  before('get the deployed bounty0x token', async () => {
    bounty0xtoken = await Bounty0xToken.deployed();
  });

  it('should be deployed', async () => {
    assert.strictEqual(typeof bounty0xtoken.address, 'string');
  });
});