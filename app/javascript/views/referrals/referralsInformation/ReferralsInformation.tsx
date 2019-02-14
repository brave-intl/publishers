import * as React from "react";

import {
  Wrapper,
  Container,
  Row,
  Content,
  Button,
  Text
} from "./ReferralsInformationStyle";

import Modal, { ModalSize } from "../../../components/modal/Modal";
import AddDialog from "./addDialog/AddDialog";
import DeleteDialog from "./deleteDialog/DeleteDialog";
import DeleteCampaignDialog from "./deleteCampaignDialog/DeleteCampaignDialog";
import EditCampaignDialog from "./editCampaignDialog/EditCampaignDialog";
import MoveDialog from "./moveDialog/MoveDialog";

import Table from "brave-ui/components/dataTables/table";
import { CloseStrokeIcon } from "brave-ui/components/icons";
import { CheckCircleIcon } from "brave-ui/components/icons";
import { SettingsAdvancedIcon } from "brave-ui/components/icons";

interface IReferralsInfoProps {}

interface IReferralsInfoState {
  date: any;
  unassigned_codes: any;
  campaigns: any;
  currentCampaign: any;
  showAddModal: boolean;
  showMoveModal: boolean;
  showDeleteModal: boolean;
  showDeleteCampaignModal: boolean;
  showEditCampaignModal: boolean;
  codeToDelete: any;
}

export default class ReferralsInformation extends React.Component<
  IReferralsInfoProps,
  IReferralsInfoState
> {
  constructor(props) {
    super(props);
    this.state = {
      date: "",
      unassigned_codes: [],
      campaigns: [],
      showDeleteModal: false,
      showAddModal: false,
      showMoveModal: false,
      showDeleteCampaignModal: false,
      showEditCampaignModal: false,
      currentCampaign: { name: "load", promo_registrations: [] },
      codeToDelete: null
    };
    this.fetchData = this.fetchData.bind(this);
  }

  componentDidMount() {
    this.fetchData();
    // alert(window.location.pathname.split("/").pop())
  }

  componentDidUpdate() {
    // this.fetchData();
  }

  async fetchData() {
    // add publisher id
    let url = "/partners/referrals/";
    let options = {
      method: "GET",
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json",
        "X-Requested-With": "XMLHttpRequest"
      }
    };
    let response = await fetch(url, options);
    let data = await response.json();
    let currentCampaign = findCurrentCampaign(data.campaigns);
    this.setState({
      unassigned_codes: data.unassigned_codes,
      campaigns: data.campaigns,
      currentCampaign: currentCampaign
    });
  }

  render() {
    return (
      <Container>
        <Row campaign>
          <Content campaignIcon>
            <CheckCircleIcon />
          </Content>
          <Content>
            <Text header>Campaign</Text>
            <Text h2>{this.state.currentCampaign.name}</Text>
          </Content>
          <Content>
            <Text header>Downloads</Text>
            <Text h2>
              {processDownloads(this.state.currentCampaign.promo_registrations)}
            </Text>
          </Content>
          <Content>
            <Text header>Installs</Text>
            <Text h2>
              {processInstalls(this.state.currentCampaign.promo_registrations)}
            </Text>
          </Content>
          <Content>
            <Text header>30-Day-Use</Text>
            <Text h2>
              {processThirtyDayUse(
                this.state.currentCampaign.promo_registrations
              )}
            </Text>
          </Content>
          <Content closeIcon>
            <div
              style={{ cursor: "pointer" }}
              onClick={this.triggerDeleteCampaignModal}
            >
              <CloseStrokeIcon />
            </div>
            <div
              style={{ cursor: "pointer" }}
              onClick={this.triggerEditCampaignModal}
            >
              <SettingsAdvancedIcon />
            </div>
          </Content>
        </Row>
        <Row lineBreak />
        <Row>
          <Content created>
            <Text h4>Created</Text>
            <Text style={{ paddingLeft: "8px" }} p>
              {processDate(this.state.currentCampaign.created_at)}
            </Text>
          </Content>
        </Row>
        <Row>
          <Content total>
            <Text h4>Total Referral Codes</Text>
            <Text style={{ paddingLeft: "8px" }} p>
              {this.state.currentCampaign.promo_registrations.length}
            </Text>
          </Content>
        </Row>
        <Row buttons>
          <Content buttons>
            <Button onClick={this.triggerAddModal}>Add Codes</Button>
            <Button style={{marginLeft: "8px"}} onClick={this.triggerMoveModal}>Move Codes</Button>
          </Content>
          <br />
          <br />
        </Row>
        <ReferralsTable
          referralCodes={this.state.currentCampaign.promo_registrations}
          triggerDeleteModal={this.triggerDeleteModal}
          setCodeToDelete={this.setCodeToDelete}
        />
        <Modal
          handleClose={this.triggerDeleteModal}
          show={this.state.showDeleteModal}
          size={ModalSize.ExtraSmall}
        >
          <DeleteDialog
            closeModal={this.triggerDeleteModal}
            codeID={this.state.codeToDelete}
            afterSave={this.fetchData}
          />
        </Modal>
        <Modal
          handleClose={this.triggerAddModal}
          show={this.state.showAddModal}
          size={ModalSize.ExtraSmall}
        >
          <AddDialog
            closeModal={this.triggerAddModal}
            campaign={this.state.currentCampaign}
            afterSave={this.fetchData}
          />
        </Modal>
        <Modal
          handleClose={this.triggerMoveModal}
          show={this.state.showMoveModal}
          size={ModalSize.ExtraSmall}
        >
          <MoveDialog
            closeModal={this.triggerMoveModal}
            campaigns={this.state.campaigns}
            referralCodes={this.state.currentCampaign.promo_registrations}
            afterSave={this.fetchData}
          />
        </Modal>
        <Modal
          handleClose={this.triggerDeleteCampaignModal}
          show={this.state.showDeleteCampaignModal}
          size={ModalSize.ExtraSmall}
        >
          <DeleteCampaignDialog
            closeModal={this.triggerDeleteCampaignModal}
            campaign={this.state.currentCampaign}
            referralCodes={this.state.currentCampaign.promo_registrations}
            afterSave={redirectToReferrals}
          />
        </Modal>
        <Modal
          handleClose={this.triggerEditCampaignModal}
          show={this.state.showEditCampaignModal}
          size={ModalSize.ExtraSmall}
        >
          <EditCampaignDialog
            closeModal={this.triggerEditCampaignModal}
            campaign={this.state.currentCampaign}
            afterSave={this.fetchData}
          />
        </Modal>
      </Container>
    );
  }

  private triggerAddModal = () => {
    this.setState({ showAddModal: !this.state.showAddModal });
  };

  private triggerMoveModal = () => {
    this.setState({ showMoveModal: !this.state.showMoveModal });
  };

  private triggerDeleteModal = () => {
    this.setState({ showDeleteModal: !this.state.showDeleteModal });
  };

  private triggerEditCampaignModal = () => {
    this.setState({ showEditCampaignModal: !this.state.showEditCampaignModal });
  };

  private triggerDeleteCampaignModal = () => {
    this.setState({
      showDeleteCampaignModal: !this.state.showDeleteCampaignModal
    });
  };

  private setCodeToDelete = codeID => {
    this.setState({
      codeToDelete: codeID
    });
  };
}

function processDownloads(referralCodes) {
  let downloads = 0;
  referralCodes.forEach(function(code) {
    downloads += JSON.parse(code.stats)[0].retrievals;
  });
  return downloads;
}

function processInstalls(referralCodes) {
  let installs = 0;
  referralCodes.forEach(function(code) {
    installs += JSON.parse(code.stats)[0].first_runs;
  });
  return installs;
}

function processThirtyDayUse(referralCodes) {
  let thirtyDayUse = 0;
  referralCodes.forEach(function(code) {
    thirtyDayUse += JSON.parse(code.stats)[0].finalized;
  });
  return thirtyDayUse;
}

function processDate(created) {
  let options = { year: "numeric", month: "long", day: "numeric" };
  let date = new Date(created);
  return date.toLocaleDateString("en-US", options);
}

function copyLink(referral_code){
  //javscript magick for copying to clipboard
  const el = document.createElement('textarea');
  el.value = "https://brave.com/" + referral_code;
  document.body.appendChild(el);
  el.select();
  document.execCommand('copy');
  document.body.removeChild(el);
  alert("Copied! " + el.value)
}

function findCurrentCampaign(campaigns) {
  let currentCampaign;
  campaigns.forEach(function(campaign, index) {
    if (
      campaign.promo_campaign_id === window.location.pathname.split("/").pop()
    ) {
      currentCampaign = campaign;
    }
  });
  return currentCampaign;
}

function redirectToReferrals() {
  window.location.replace("/partners/referrals");
}

function ReferralsTable(props) {
  let header = [
    {
      content: "Referral Code",
      customStyle: {
        "font-size": "15px",
        "text-align": "center",
        "opacity": ".7"
        padding: "20px"
      }
    },
    {
      content: "Description",
      customStyle: {
        "font-size": "15px",
        "text-align": "center",
        "opacity": ".7"
        padding: "20px"
      }
    },
    {
      content: "Downloads",
      customStyle: {
        "font-size": "15px",
        "text-align": "center",
        "opacity": ".7"
        padding: "20px"
      }
    },
    {
      content: "Installs",
      customStyle: {
        "font-size": "15px",
        "text-align": "center",
        "opacity": ".7"
        padding: "20px"
      }
    },
    {
      content: "30-Day-Use",
      customStyle: {
        "font-size": "15px",
        "text-align": "center",
        "opacity": ".7"
        padding: "20px"
      }
    },
    {
      content: "Actions",
      customStyle: {
        "font-size": "15px",
        "text-align": "center",
        "opacity": ".7"
        padding: "20px"
      }
    }
  ];

  let rows = [];

  props.referralCodes.forEach(function(referralCode, index) {
    let content = {
      content: [
        {
          content: <div key={index}>{referralCode.referral_code}</div>,
          customStyle: {
            "font-size": "15px",
            "text-align": "center",
            padding: "24px"
          }
        },
        {
          content: <div key={index}>{referralCode.description === "null" ? "" : referralCode.description}</div>,
          customStyle: {
            "font-size": "15px",
            "text-align": "center",
            padding: "24px"
          }
        },
        {
          content: (
            <div key={index}>
              {JSON.parse(referralCode.stats)[0].retrievals}
            </div>
          ),
          customStyle: {
            "font-size": "15px",
            "text-align": "center",
            padding: "24px"
          }
        },
        {
          content: (
            <div key={index}>
              {JSON.parse(referralCode.stats)[0].first_runs}
            </div>
          ),
          customStyle: {
            "font-size": "15px",
            "text-align": "center",
            padding: "24px"
          }
        },
        {
          content: (
            <div key={index}>{JSON.parse(referralCode.stats)[0].finalized}</div>
          ),
          customStyle: {
            "font-size": "15px",
            "text-align": "center",
            padding: "24px"
          }
        },
        {
          content: (
            <div key={index} style={{display: 'flex', justifyContent: 'space-around'}}>
            <div
              key={index}
              style={{ cursor: "pointer", userSelect: "none" }}
              onClick={() => {copyLink(referralCode.referral_code)}}
            >
              Copy Link
            </div>
            <div
            key={index}
            style={{ cursor: "pointer", userSelect: "none" }}
            onClick={() => {
              props.setCodeToDelete(referralCode.id);
              props.triggerDeleteModal();
            }}
          >
            Delete
          </div>
          </div>
          ),
          customStyle: {
            "font-size": "15px",
            "text-align": "center",
            padding: "24px"
          }
        }
      ]
    };
    rows.push(content);
  });
  return (
    <div>
      <Table header={header} rows={rows}>
        &nbsp;
      </Table>
    </div>
  );
}
