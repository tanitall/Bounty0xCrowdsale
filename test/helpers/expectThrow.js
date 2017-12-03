export default async promise => {
  try {
    await promise;
  } catch (error) {
    const { message } = error;

    const invalidOpcode = message.indexOf('invalid opcode') >= 0;

    assert(
      invalidOpcode,
      'Expected throw, got \"' + message + '\" instead',
    );
    return;
  }
  assert.fail('Expected throw not received');
};