import { ZERO_ADDRESS } from './helpers/util';

const Bounty0xToken = artifacts.require('Bounty0xToken');
const Bounty0xCrowdsale = artifacts.require('Bounty0xCrowdsale');
const MiniMeTokenFactory = artifacts.require('MiniMeTokenFactory');

contract('Bounty0xToken', (accounts) => {
  let token;
  let crowdsale;
  let factory;

  before('get the deployed bounty0x token', async () => {
    token = await Bounty0xToken.deployed();
    crowdsale = await Bounty0xCrowdsale.deployed();
    factory = await MiniMeTokenFactory.deployed();
  });

  it('should be deployed', async () => {
    assert.strictEqual(typeof token.address, 'string');
  });

  it('controller should be Bounty0xCrowdsale', async () => {
    const controller = await token.controller();
    assert.strictEqual(controller, crowdsale.address);
  });

  it('should have a token factory', async () => {
    const minime = await token.tokenFactory();
    assert.strictEqual(minime, factory.address);
  });

  it('should have the constant attributes', async () => {
    //  0x0,                        // no parent token
    //  0,                          // no snapshot block number from parent
    //  "Bounty0x Token",           // Token name
    //  18   ,                      // Decimals
    //  "BNTY",                     // Symbol
    //  true                       // Enable transfers

    const parentSnapShotBlock = await token.parentSnapShotBlock();
    const parentToken = await token.parentToken();
    const name = await token.name();
    const decimals = await token.decimals();
    const symbol = await token.symbol();
    const transfersEnabled = await token.transfersEnabled();

    assert.strictEqual(parentSnapShotBlock.valueOf(), '0');
    assert.strictEqual(parentToken, ZERO_ADDRESS);
    assert.strictEqual(name, 'Bounty0x Token');
    assert.strictEqual(decimals.valueOf(), '18');
    assert.strictEqual(symbol, 'BNTY');
    assert.strictEqual(transfersEnabled, true);
  });
});