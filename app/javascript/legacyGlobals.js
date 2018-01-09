import dynamicEllipsis from 'utils/dynamicEllipsis';
import {
  fetchAfterDelay,
  pollUntilSuccess,
  submitForm
} from 'utils/request';
import flash from 'utils/flash';
import spinner from 'utils/spinner';

window.dynamicEllipsis = dynamicEllipsis;
window.fetchAfterDelay = fetchAfterDelay;
window.pollUntilSuccess = pollUntilSuccess;
window.submitForm = submitForm;
window.flash = flash;
window.spinner = spinner;
