import { add } from 'example';

const { module, test } = QUnit;

module('Example tests', function() {
  test('2 + 2 = 4', function(assert) {
    assert.equal(add(2, 2), 4, 'example test works');
  });
});
