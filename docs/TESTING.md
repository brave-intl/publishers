# Testing

We generally recommend running tests individually in the docker context.

To easily attach to the docker web container

```
make docker-shell
```

Once attached to the container, individual tests can be run with:

```
rails test test/path/to/test_test.rb
```

The full test suite is most readily executed in CI and should be triggered by pushing to the remote.


We use capybara which runs selenium tests, which depends on chromium.
If you don't installed, you'll get an error "can't find chrome binary".
On debian you can install it like:

```sh
sudo apt-get install chromium
```

And on mac with:

```
brew install chromium
```

If you are using an M1 chip, the tests that depend on selenium will error. You can still run the tests that don't use selenium locally. The selenium errors are displayed separately from test failures at the end.  The test suite will still run in full when a pull request is created.

We use [ThumbnailWasm](https://github.com/brave-intl/wasm-thumbnail) to process user uploaded images. You'll need rust installed to compile it, see https://rustup.rs/ for more details.

### Javascript

We use jest for our javascript testing framework. You can run the tests through the following command.

```sh
yarn test
```


