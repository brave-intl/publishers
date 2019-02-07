import * as React from "react";

import locale from "../../../../locale/en";

import { Header, PrimaryButton } from "./MoveDialogStyle";

import Checkbox from "brave-ui/components/formControls/checkbox";
import Table from "brave-ui/components/dataTables/table";

const initialState = { isLoading: false, errorText: "" };

interface IMoveDialogProps {
  closeModal: any;
  referralCodes: any;
  campaigns: any;
}

interface IMoveDialogState {
  selectedCodes: any;
  selectedCampaign: any;
  campaignValue: any;
  codesValue: any;
}

export default class MoveDialog extends React.Component<
  IMoveDialogProps,
  IMoveDialogState
> {
  constructor(props) {
    super(props);
    this.state = {
      selectedCodes: [],
      selectedCampaign: null,
      campaignValue: null,
      codesValue: null
    };
  }

  handleCampaignSelect = e => {
    this.setState({ selectedCampaign: e.target.value });
  };
  handleCodeSelect = (e, id) => {
    let temp = this.state.selectedCodes;
    if (e.target.checked) {
      temp.push(id);
      this.setState({ selectedCodes: temp });
    } else {
      let index = temp.indexOf(id);
      if (index > -1) {
        temp.splice(index, 1);
      }
      this.setState({ selectedCodes: temp });
    }
  };

  public render() {
    return (
      <div>
        <Header>Move referral code?</Header>
        <CodesList
          referralCodes={this.props.referralCodes}
          handleCodeSelect={this.handleCodeSelect}
        />
        <br />
        <CampaignDropdown
          campaigns={this.props.campaigns}
          handleCampaignSelect={this.handleCampaignSelect}
        />
        <br />
        <PrimaryButton
          enabled={true}
          onClick={() =>
            moveCodes(
              this.state.selectedCodes,
              this.state.selectedCampaign,
              this.props.closeModal
            )
          }
        >
          Move
        </PrimaryButton>
      </div>
    );
  }
}

async function moveCodes(selectedCodes, selectedCampaign, closeModal) {
  let url = "/partners/referrals/move_codes";
  let body = new FormData();
  body.append("codes", JSON.stringify(selectedCodes));
  body.append("campaign", selectedCampaign);
  let options = {
    method: "POST",
    headers: {
      Accept: "application/json",
      "X-Requested-With": "XMLHttpRequest",
      "X-CSRF-Token": document.head
        .querySelector("[name=csrf-token]")
        .getAttribute("content")
    },
    body: body
  };
  let response = await fetch(url, options);
  closeModal();
  return;
}

function CodesList(props) {
  let header = [{ content: "Referral Code" }, { content: "Description" }];
  let rows = [];
  props.referralCodes.forEach(function(code, index) {
    let content = {
      content: [
        {
          content: (
            <div key={index}>
              <input
                onChange={e => {
                  props.handleCodeSelect(e, code.id);
                }}
                type="checkbox"
              />
              {code.referral_code}
            </div>
          )
        },
        {
          content: <div key={index}>{code.referral_code}</div>
        }
      ]
    };
    rows.push(content);
  });
  return (
    <div style={{ maxHeight: "250px", overflowY: "scroll" }}>
      <Table header={header} rows={rows}>
        Loading...
      </Table>
    </div>
  );
}

function CampaignDropdown(props) {
  let campaigns = props.campaigns;
  let dropdownOptions = props.campaigns.map((campaign, index) => (
    <option key={index} value={campaign.promo_campaign_id}>
      {campaign.name}
    </option>
  ));
  return (
    <select
      onChange={e => {
        props.handleCampaignSelect(e);
      }}
      style={{ width: "100%" }}
    >
      <option value="" disabled selected>
        Select a Campaign
      </option>
      {dropdownOptions}
    </select>
  );
}
