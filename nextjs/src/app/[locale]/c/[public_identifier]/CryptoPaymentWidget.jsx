"use client";
// one of the libraries that the QR code modal depends on references the dom, so
// it needs to be loaded with ssr set to false
import dynamic from "next/dynamic";
const QRCodeModal = dynamic(() => import("./QRCodeModal"), {
  ssr: false,
});
import { useEffect, useState, useContext } from "react";
import { useTranslations } from "next-intl";
import Dialog from "@brave/leo/react/dialog";
import Icon from "@brave/leo/react/icon";
import { CryptoWidgetContext } from "@/lib/context/CryptoWidgetContext";
import TryBraveModal from "./TryBraveModal";
import CryptoWidgetAmountSelect from "./CryptoWidgetAmountSelect";
import CryptoWidgetPaymentButton from "./CryptoWidgetPaymentButton";
import SuccessWidget from "./SuccessWidget";
import { apiRequest } from "@/lib/api";
import styles from "@/styles/PublicChannelPage.module.css";

export default function CryptoPaymentWidget({
  title,
  cryptoAddresses,
  cryptoConstants,
  previewMode,
}) {
  const t = useTranslations();
  let intervalId;
  // There shouldn't be more than one of each, but just in case
  const solAddress = cryptoAddresses.filter((address) =>
    address.includes("SOL"),
  )[0];
  const ethAddress = cryptoAddresses.filter((address) =>
    address.includes("ETH"),
  )[0];
  const addresses = {
    SOL: solAddress && solAddress[0],
    ETH: ethAddress && ethAddress[0],
  };

  const {
    currentChain,
    setCurrentChain,
    setRatios,
    displayChain,
    currentAmount,
    errorMsg,
    setErrorMsg,
    errorTitle,
    setErrorTitle,
    isSuccessView,
    setIsSuccessView,
    isTryBraveModalOpen,
  } = useContext(CryptoWidgetContext);
  const [isLoading, setIsLoading] = useState(true);
  const [isModalOpen, setIsModalOpen] = useState(false);

  useEffect(() => {
    loadData();
    // the channel must have at least one crypto address for this page to be navigable,
    // and right now the options are only sol and eth
    setCurrentChain(ethAddress ? "BAT" : "splBAT");

    if (!previewMode) {
      // Set up a setInterval to fetch new price data every 5 minutes (300,000 milliseconds)
      intervalId = setInterval(backgroundLoadData.bind(this), 300000);
    }
  }, []);

  async function backgroundLoadData() {
    const ratioData = await apiRequest(`get_ratios`);
    setRatios(ratioData);
  }

  async function loadData() {
    setIsLoading(true);
    const ratioData = await apiRequest(`get_ratios`);
    setRatios(ratioData);
    setIsLoading(false);
  }

  function roundCryptoPrice() {
    return Math.round(currentAmount * 100000) / 100000;
  }

  function baseChain() {
    if (
      currentChain.toLowerCase().includes("spl") ||
      currentChain.includes("SOL")
    ) {
      return "SOL";
    } else {
      return "ETH";
    }
  }

  function clearError() {
    setErrorTitle(null);
    setErrorMsg(null);
  }

  if (isLoading) {
    return <div className={`${styles["crypto-widget-wrapper"]}`}></div>;
  } else if (isSuccessView) {
    return (
      <SuccessWidget
        setStateToStart={() => setIsSuccessView(false)}
        amount={roundCryptoPrice()}
        chain={displayChain}
        name={title}
      />
    );
  } else {
    return (
      <div className={`${styles["crypto-widget-wrapper"]}`}>
        <div className={`${styles["heading-wrapper"]}`}>
          <div className="default-regular">
            {t("publicChannelPage.paymentSubHeading")}
          </div>
          <h3 className={`${styles["widget-heading"]}`}>
            {t("publicChannelPage.paymentHeading")}
          </h3>
        </div>
        <div className={`${styles["payment-options"]}`}>
          <CryptoWidgetAmountSelect
            ethAddress={ethAddress}
            solAddress={solAddress}
            clearError={clearError.bind(this)}
          />
          {errorTitle && (
            <div className={`${styles["error-section"]}`}>
              <div className={`${styles["error-icon"]}`}>
                <Icon name="warning-circle-filled" />
              </div>
              <div className={`${styles["error-text"]}`}>
                <div className={`${styles["error-title"]}`}>{errorTitle}</div>
                <div className={`${styles["error-message"]}`}>{errorMsg}</div>
              </div>
            </div>
          )}
        </div>
        <div className={`${styles["payment-buttons"]}`}>
          <CryptoWidgetPaymentButton
            previewMode={previewMode}
            cryptoConstants={cryptoConstants}
            addresses={addresses}
          />
          <a
            className={`${styles["qr-link"]}`}
            onClick={(event) => {
              event.preventDefault();
              setIsModalOpen(true);
            }}
          >
            {t("publicChannelPage.generateQR")}
          </a>
        </div>
        <Dialog
          isOpen={isModalOpen}
          showClose={true}
          onClose={() => setIsModalOpen(false)}
          className={`${styles["qr-modal"]}`}
        >
          <QRCodeModal
            address={addresses[baseChain()]}
            chain={baseChain()}
            displayChain={displayChain}
          />
        </Dialog>
        <Dialog
          isOpen={isTryBraveModalOpen}
          showClose={true}
          onClose={() => isTryBraveModalOpen(false)}
          className={`${styles["try-brave-modal"]}`}
        >
          <TryBraveModal />
        </Dialog>
      </div>
    );
  }
}
