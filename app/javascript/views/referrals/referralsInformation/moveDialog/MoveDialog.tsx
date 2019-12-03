import * as React from "react";

import locale from "../../../../locale/en";

import Table from "brave-ui/components/dataTables/table";
import { ErrorText, Header, PrimaryButton } from "./MoveDialogStyle";

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
  errorText: string;
}

export default class MoveDialog extends React.Component<
  IMoveDialogProps,
  IMoveDialogState
> {
  constructor(props) {
    super(props);
    this.state = {
      campaignValue: null,
      codesValue: null,
      errorText: "",
      selectedCampaign: null,
      selectedCodes: []
    };
  }

  public isValidForm = () => {
    if (
      this.state.selectedCodes.length > 0 &&
      this.state.selectedCampaign !== null
    ) {
      return true;
    } else {
      return false;
    }
  };

  public async moveCodes(
    selectedCodes,
    selectedCampaign,
    closeModal,
    afterSave
  ) {
    const url =
      "/partners/referrals/promo_registrations/" + selectedCodes.join(",");
    const body = new FormData();
    body.append("campaign", selectedCampaign);
    const options = {
      body,
      headers: {
        Accept: "application/json",
        "X-CSRF-Token": document.head
          .querySelector("[name=csrf-token]")
          .getAttribute("content"),
        "X-Requested-With": "XMLHttpRequest"
      },
      method: "PUT"
    };
    const response = await fetch(url, options);
    if (response.status >= 400) {
      this.setState({
        errorText: "An unexpected error has occurred. Please try again later."
      });
      return;
    }
    afterSave();
    closeModal();
    return;
  }

  public handleCampaignSelect = e => {
    this.setState({ selectedCampaign: e.target.value });
  };
  public handleCodeSelect = (e, id) => {
    const temp = this.state.selectedCodes;
    if (e.target.checked) {
      temp.push(id);
      this.setState({ selectedCodes: temp });
    } else {
      const index = temp.indexOf(id);
      if (index > -1) {
        temp.splice(index, 1);
      }
      this.setState({ selectedCodes: temp });
    }
  };

  public render() {
    return (
      <div>
        <Header>{locale.referrals.moveReferralCodes}</Header>
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
        {this.isValidForm() === true ? (
          <PrimaryButton
            enabled={true}
            onClick={() =>
              this.moveCodes(
                this.state.selectedCodes,
                this.state.selectedCampaign,
                this.props.closeModal,
                this.props.afterSave
              )
            }
          >
            {locale.move}
          </PrimaryButton>
        ) : (
          <PrimaryButton enabled={false}>{locale.move}</PrimaryButton>
        )}
        <ErrorText>{this.state.errorText}</ErrorText>
      </div>
    );
  }
}

function CodesList(props) {
  const header = [
    {
      content: "Referral Code",
      customStyle: {
        "font-size": "15px",
        "margin-left": "24px",
        opacity: ".7",
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
  const rows = [];
  props.referralCodes.forEach((code, index) => {
    const content = {
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
  const campaigns = props.campaigns;
  const dropdownOptions = props.campaigns.map((campaign, index) => (
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
