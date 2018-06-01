import {
  pollUntilSuccess,
  submitForm
} from '../utils/request';
import dynamicEllipsis from '../utils/dynamicEllipsis';
import spinner from 'utils/spinner';

function formatDate(date) {
  return date.toLocaleDateString("en-US", { month: 'short', day: 'numeric' });
}

let generating = false;

document.addEventListener('DOMContentLoaded', function() {
  if (document.querySelectorAll('body[data-action="statements"]').length === 0) {
    return;
  }

  let generateStatement = document.getElementById('generate_statement');
  let statementGenerator = document.getElementById('statement_generator');
  let statementPeriod = document.getElementById('statement_period');
  let generatedStatements = document.getElementById('generated_statements');

  if (generateStatement) {
    generateStatement.addEventListener('click', function(event) {
      let statementId;
      let statementDownloadDiv;

      event.preventDefault();
      if (generating) return;

      generating = true;
      spinner.show();

      submitForm('statement_generator', 'PATCH', false)
        .then(function(response) {
          return response.json();
        })
        .then(function(json) {
          statementPeriod.options.remove(statementPeriod.selectedIndex);
          if (statementPeriod.options.length === 0) {
            statementGenerator.classList.add('hidden');
          }

          let newStatementDiv = document.createElement('div');
          newStatementDiv.className = 'statement';

          let statementCreatedAtDiv = document.createElement('div');
          statementCreatedAtDiv.className = 'created-at';
          statementCreatedAtDiv.appendChild(document.createTextNode(formatDate(new Date())));
          newStatementDiv.appendChild(statementCreatedAtDiv);

          let statementPeriodDiv = document.createElement('div');
          statementPeriodDiv.className = 'period';
          statementPeriodDiv.appendChild(document.createTextNode(json.period));
          newStatementDiv.appendChild(statementPeriodDiv);

          statementDownloadDiv = document.createElement('div');
          statementDownloadDiv.className = 'status';
          statementDownloadDiv.appendChild(document.createTextNode('Generating'));
          newStatementDiv.appendChild(statementDownloadDiv);

          generatedStatements.insertBefore(newStatementDiv, generatedStatements.firstChild);

          dynamicEllipsis.start(statementDownloadDiv);

          statementId = json.id;
          return pollUntilSuccess('/publishers/statement_ready?id=' + statementId, 3000, 2000, 7);
        })
        .then(function() {
          dynamicEllipsis.stop(statementDownloadDiv);
          statementDownloadDiv.innerHTML = '<span>Ready</span>' +
            '<a class="download" data-piwik-action="DownloadPublisherStatement" ' +
               'data-piwik-name="Clicked" data-piwik-value="Dashboard" ' +
               'href="/publishers/statement?id=' + statementId + '">Download</a>';
          spinner.hide();
          generating = false;
        })
        .catch(function(e) {
          if (statementDownloadDiv) {
            dynamicEllipsis.stop(statementDownloadDiv);
            statementDownloadDiv.innerText = 'Delayed';
          }
          spinner.hide();
          generating = false;
        });
    }, false);
  }
});
