const fs = require('fs');
const path = require('path');

const files = [
  [
    path.join(__dirname, '..', 'node_modules', '@brave', 'leo', 'icons'),
    path.join(__dirname, '..', 'public', 'icons'),
  ],
];

for (let [source, destination] of files) {
  /**
   * If we don't explicitly include the destination filename, Windows
   * may not complete this step. A trailing / will be taken as a signal
   * that the source filename is to be preserved. When encountered, we
   * will extract the source filename, and add it to the destination.
   */
  if (destination.endsWith('/')) {
    const { base: filename } = path.parse(source);
    destination = path.join(destination, filename);
  }
  console.log('success!');
  fs.cpSync(source, destination, { recursive: true });
}
