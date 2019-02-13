import * as React from "react";

import locale from "../../../../locale/en";

import { Header, PrimaryButton } from "./MoveDialogStyle";

import Checkbox from "brave-ui/components/formControls/checkbox";
import Table from "brave-ui/components/dataTables/table";

const initialState = { isLoading: false, errorText: "" };

interface IMoveDialogProps {
  closeModal: any;
  afterSave: () => void;
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
        <br />
        <PrimaryButton
          enabled={true}
          onClick={() =>
            moveCodes(
              this.state.selectedCodes,
              this.state.selectedCampaign,
              this.props.closeModal,
              this.props.afterSave
            )
          }
        >
          Move
        </PrimaryButton>
      </div>
    );
  }
}

async function moveCodes(
  selectedCodes,
  selectedCampaign,
  closeModal,
  afterSave
) {
  let url =
    "/partners/referrals/promo_registrations/" + selectedCodes.join(",");
  let body = new FormData();
  body.append("campaign", selectedCampaign);
  let options = {
    method: "PUT",
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
  afterSave();
  closeModal();
  return;
}

function CodesList(props) {
  let header = [
    {
      content: "Referral Code",
      customStyle: {
        "font-size": "15px",
        opacity: ".7",
        "margin-left": "24px",
        padding: "10px"
      }
    },
    {
      content: "Description",
      customStyle: {
        "font-size": "15px",
        opacity: ".7",
        padding: "10px"
      }
    }
  ];
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
              &nbsp;
              {code.referral_code}
            </div>
          ),
          customStyle: {
            "font-size": "15px",
            "margin-left": "24px",
            padding: "10px"
          }
        },
        {
          content: <div key={index}>{code.referral_code}</div>,
          customStyle: {
            "font-size": "15px",
            padding: "10px"
          }
        }
      ]
    };
    rows.push(content);
  });
  return (
    <div style={{ maxHeight: "260px", overflowY: "scroll" }}>
      <Table header={header} rows={rows}>
        &nbsp;
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
