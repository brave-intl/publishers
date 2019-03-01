import * as React from "react";

import {
  Button,
  Container,
  Content,
  Row,
  Text
} from "./ReferralsInformationStyle";

import Modal, { ModalSize } from "../../../components/modal/Modal";
import locale from "../../../locale/en";

import AddDialog from "./addDialog/AddDialog";
import DeleteCampaignDialog from "./deleteCampaignDialog/DeleteCampaignDialog";
import DeleteDialog from "./deleteDialog/DeleteDialog";
import EditCampaignDialog from "./editCampaignDialog/EditCampaignDialog";
import MoveDialog from "./moveDialog/MoveDialog";

import Table from "brave-ui/components/dataTables/table";

import { ICampaign } from "../Referrals";

import {
  CheckCircleIcon,
  CloseStrokeIcon,
  SettingsAdvancedIcon
} from "brave-ui/components/icons";

interface IReferralsInfoState {
  campaigns: ICampaign[];
  currentCampaign: ICampaign;
  showAddModal: boolean;
  showMoveModal: boolean;
  showDeleteModal: boolean;
  showDeleteCampaignModal: boolean;
  showEditCampaignModal: boolean;
  stats: any;
  codeToDelete: string;
}

export default class ReferralsInformation extends React.Component<
  {},
  IReferralsInfoState
> {
  constructor(props) {
    super(props);
    this.state = {
      campaigns: [],
      codeToDelete: null,
      currentCampaign: {
        created_at: null,
        name: "fetching...",
        promo_campaign_id: null,
        promo_registrations: []
      },
      showAddModal: false,
      showDeleteCampaignModal: false,
      showDeleteModal: false,
      showEditCampaignModal: false,
      showMoveModal: false,
      stats: {}
    };
    this.fetchData = this.fetchData.bind(this);
  }

  public componentDidMount() {
    this.fetchData();
  }

  public async fetchData() {
    const url = "/partners/referrals/";
    const options = {
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json",
        "X-Requested-With": "XMLHttpRequest"
      },
      method: "GET"
    };
    const response = await fetch(url, options);
    const data = await response.json();
    const currentCampaign = findCurrentCampaign(data.campaigns);
    this.setState({
      campaigns: data.campaigns,
      currentCampaign,
      stats: processStats(currentCampaign.promo_registrations)
    });
  }

  public render() {
    return (
      <Container>
        <Row campaign>
          <Content campaignIcon>
            <CheckCircleIcon />
          </Content>
          <Content>
            <Text header>{locale.campaigns}</Text>
            <Text h2>{this.state.currentCampaign.name}</Text>
          </Content>
          <Content>
            <Text header>{locale.downloads}</Text>
            <Text h2>{this.state.stats.downloads}</Text>
          </Content>
          <Content>
            <Text header>{locale.installs}</Text>
            <Text h2>{this.state.stats.installs}</Text>
          </Content>
          <Content>
            <Text header>{locale.thirtyDay}</Text>
            <Text h2>{this.state.stats.thirtyDayUse}</Text>
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
            <Text h4>{locale.created}</Text>
            <Text style={{ paddingLeft: "8px" }} p>
              {processDate(this.state.currentCampaign.created_at)}
            </Text>
          </Content>
        </Row>
        <Row>
          <Content total>
            <Text h4>{locale.referrals.totalReferralCodes}</Text>
            <Text style={{ paddingLeft: "8px" }} p>
              {this.state.currentCampaign.promo_registrations.length}
            </Text>
          </Content>
        </Row>
        <Row buttons>
          <Content buttons>
            <Button onClick={this.triggerAddModal}>
              {locale.referrals.addCodes}
            </Button>
            <Button
              style={{ marginLeft: "8px" }}
              onClick={this.triggerMoveModal}
            >
              {locale.referrals.moveCodes}
            </Button>
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

function processStats(referralCodes) {
  let downloads = 0;
  let installs = 0;
  let thirtyDayUse = 0;
  referralCodes.forEach(code => {
    downloads += JSON.parse(code.stats)[0].retrievals;
    installs += JSON.parse(code.stats)[0].first_runs;
    thirtyDayUse += JSON.parse(code.stats)[0].finalized;
  });
  return { downloads, installs, thirtyDayUse };
}

function processDate(created) {
  const options = { year: "numeric", month: "long", day: "numeric" };
  const date = new Date(created);
  return date.toLocaleDateString("en-US", options);
}

function copyLink(referralCode) {
  // Copy to Clipboard
  const el = document.createElement("textarea");
  el.value = "https://brave.com/" + referralCode;
  document.body.appendChild(el);
  el.select();
  document.execCommand("copy");
  document.body.removeChild(el);
  alert("Copied! " + el.value);
}

function findCurrentCampaign(campaigns) {
  let currentCampaign;
  campaigns.forEach((campaign, index) => {
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
  const headerStyle = {
    "font-size": "15px",
    opacity: ".7",
    padding: "20px",
    "text-align": "center"
  };
  const header = [
    {
      content: locale.referralCode,
      customStyle: headerStyle
    },
    {
      content: locale.description,
      customStyle: headerStyle
    },
    {
      content: locale.downloads,
      customStyle: headerStyle
    },
    {
      content: locale.installs,
      customStyle: headerStyle
    },
    {
      content: locale.thirtyDay,
      customStyle: headerStyle
    },
    {
      content: locale.actions,
      customStyle: headerStyle
    }
  ];

  const rows = [];

  props.referralCodes.forEach((referralCode, index) => {
    const contentStyle = {
      "font-size": "15px",
      padding: "24px",
      "text-align": "center"
    };
    const content = {
      content: [
        {
          content: <div>{referralCode.referral_code}</div>,
          customStyle: contentStyle
        },
        {
          content: (
            <div>
              {referralCode.description === "null"
                ? ""
                : referralCode.description}
            </div>
          ),
          customStyle: contentStyle
        },
        {
          content: <div>{JSON.parse(referralCode.stats)[0].retrievals}</div>,
          customStyle: contentStyle
        },
        {
          content: <div>{JSON.parse(referralCode.stats)[0].first_runs}</div>,
          customStyle: contentStyle
        },
        {
          content: <div>{JSON.parse(referralCode.stats)[0].finalized}</div>,
          customStyle: contentStyle
        },
        {
          content: (
            <div style={{ display: "flex", justifyContent: "space-around" }}>
              <div
                style={{ cursor: "pointer", userSelect: "none" }}
                onClick={() => {
                  copyLink(referralCode.referral_code);
                }}
              >
                {locale.copyLink}
              </div>
              <div
                style={{ cursor: "pointer", userSelect: "none" }}
                onClick={() => {
                  props.setCodeToDelete(referralCode.id);
                  props.triggerDeleteModal();
                }}
              >
                {locale.delete}
              </div>
            </div>
          ),
          customStyle: contentStyle
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
