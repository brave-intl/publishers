/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at http://mozilla.org/MPL/2.0/. */

 const Enzyme = require('enzyme')
 const EnzymeAdapter = require('enzyme-adapter-react-16')
 require('jest-styled-components')

 // Setup enzyme's react adapter
 Enzyme.configure({ adapter: new EnzymeAdapter() })
