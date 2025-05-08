"use client";

import { useState, useContext } from "react";
import { useTranslations } from "next-intl";

import Icon from "@brave/leo/react/icon";
import Select, { components } from "react-select";
import { CryptoWidgetContext } from "@/lib/context/CryptoWidgetContext";
import CryptoPaymentOption from "./CryptoPaymentOption";
import styles from "@/styles/PublicChannelPage.module.css";

export default function CryptoWidgetAmountSelect({
  clearError,
  ethAddress,
  solAddress,
}) {
  const t = useTranslations();

  const placeholder = t("publicChannelPage.custom");
  const iconOptions = {
    SOL: "sol-color",
    ETH: "eth-color",
    BAT: "bat-color",
    USDC: "usdc-color",
  };
  const defaultAmounts = [1, 5, 10];

  const dropdownOptions = [];
  if (ethAddress) {
    dropdownOptions.push({
      label: t("publicChannelPage.ethereumNetwork"),
      options: [
        {
          label: t("walletServices.addCryptoWidget.ethereum"),
          subheading: t("publicChannelPage.ethSubheading"),
          value: "ETH",
          icon: "eth-color",
        },
        {
          label: t("walletServices.addCryptoWidget.ethereumBAT"),
          subheading: t("publicChannelPage.ethBatSubheading"),
          value: "BAT",
          icon: "bat-color",
        },
        {
          label: t("publicChannelPage.usdc"),
          subheading: t("publicChannelPage.usdcSubheading"),
          value: "USDC",
          icon: "usdc-color",
        },
      ],
    });
  }

  if (solAddress) {
    dropdownOptions.push({
      label: t("publicChannelPage.solanaNetwork"),
      options: [
        {
          label: t("walletServices.addCryptoWidget.solana"),
          subheading: t("publicChannelPage.solSubheading"),
          value: "SOL",
          icon: "sol-color",
        },
        {
          label: t("walletServices.addCryptoWidget.solanaBAT"),
          subheading: t("publicChannelPage.solBatSubheading"),
          value: "splBAT",
          icon: "bat-color",
        },
        {
          label: t("publicChannelPage.solUsdc"),
          subheading: t("publicChannelPage.solUsdcSubheading"),
          value: "USDC-SPL",
          icon: "usdc-color",
        },
      ],
    });
  }

  const {
    currentChain,
    setCurrentChain,
    ratios,
    displayChain,
    setDisplayChain,
    currentAmount,
    setCurrentAmount,
  } = useContext(CryptoWidgetContext);
  const [customAmount, setCustomAmount] = useState(null);
  const [dollarValue, setDollarValue] = useState(5);
  const [displayCrypto, setDisplayCrypto] = useState(false);
  const [selectValue, setSelectValue] = useState(
    dropdownOptions
      .flatMap((opt) => opt.options)
      .filter((opt) => opt.value === currentChain)[0],
  );

  function calculateUSDPrice(amount) {
    amount = amount || currentAmount;
    if (displayChain.includes("USDC")) {
      return Math.round(amount * 100) / 100;
    } else {
      return (
        Math.round(amount * ratios[displayChain.toLowerCase()]["usd"] * 100) /
        100
      );
    }
  }

  function calculateCryptoPrice(usd, chain) {
    chain = chain || displayChain;
    if (chain.includes("USDC")) {
      return usd;
    } else {
      return usd / ratios[chain.toLowerCase()]["usd"];
    }
  }

  function roundCryptoPrice() {
    return Math.round(currentAmount * 100000) / 100000;
  }

  function changeChain(optionVal) {
    setCurrentChain(optionVal.value);
    setSelectValue(optionVal);
    const chain = optionVal.value.includes("BAT")
      ? "BAT"
      : optionVal.value.includes("USDC")
        ? "USDC"
        : optionVal.value;
    setDisplayChain(chain);
    clearError();
    // keep the value the same in terms of dollars when the chain is switched
    setCurrentAmount(calculateCryptoPrice(dollarValue, chain));
  }

  function updateAmount(amount) {
    // if dollar input has been selected
    if (!displayCrypto) {
      setCurrentAmount(calculateCryptoPrice(amount));
      setDollarValue(amount);
      // if crypto input has been selected
    } else {
      setCurrentAmount(amount);
      setDollarValue(calculateUSDPrice(amount));
    }
  }

  function handleInputChange(event) {
    const customValue = event.target.value
      ? parseFloat(event.target.value)
      : null;
    setCustomAmount(customValue);
    updateAmount(customValue);
  }

  function handleDisplayCryptoChange() {
    setDisplayCrypto(!displayCrypto);
    displayCrypto
      ? setCustomAmount(calculateUSDPrice())
      : setCustomAmount(currentAmount);
  }

  return (
    <>
      {/*Chain dropdown*/}
      <Select
        options={dropdownOptions}
        onChange={changeChain}
        components={{
          SingleValue: ({ children, ...rest }) => (
            <components.SingleValue {...rest} className="flex">
              <Icon
                name={`${iconOptions[displayChain]}`}
                className={`mr-2 ${styles["value-icon-image"]}`}
              />
              <div>
                {children}
                <div className={`${styles["crypto-option-subheading"]}`}>
                  {rest.data.subheading}
                </div>
              </div>
            </components.SingleValue>
          ),
          Option: CryptoPaymentOption,
        }}
        className="crypto-currency-dropdown"
        value={selectValue}
        styles={{
          control: (base) => ({
            ...base,
            boxShadow: "none",
            borderColor: "rgba(161, 178, 186, 0.4)",
            padding: "0px 16px",
            borderRadius: "8px",
          }),
          groupHeading: (base) => ({
            ...base,
            textAlign: "left",
            fontSize: "11px",
            backgroundColor: "rgba(243, 245, 247, 1)",
            padding: "12px 16px",
          }),
          group: (base) => ({ ...base, padding: "0px" }),
          indicatorSeparator: (base) => ({ ...base, display: "none" }),
          dropdownIndicator: (base) => ({
            ...base,
            padding: "0px",
            color: "rgba(98, 117, 126, 1)",
          }),
          input: (base) => ({ ...base, caretColor: "transparent" }),
          valueContainer: (base) => ({
            ...base,
            display: "flex",
            textAlign: "left",
            padding: "16px",
            paddingLeft: "0px",
            fontWeight: "600",
          }),
          menu: (base) => ({
            ...base,
            marginTop: "0px",
            borderRadius: "8px",
            boxShadow:
              "0px 4px 16px -2px rgba(0, 0, 0, 0.1), 0px 1px 0px 0px rgba(0, 0, 0, 0.05)",
            overflow: "hidden",
          }),
          menuList: (base) => ({
            ...base,
            maxHeight: "500px",
            paddingTop: "0px",
          }),
        }}
      />
      <div className="grid grid grid-cols-12 pb-4 pt-4">
        {/* amount inputs */}
        <div className="col-span-12 md:col-span-7 text-left">
          {!displayCrypto &&
            defaultAmounts.map((amount) => {
              return (
                <button
                  key={amount}
                  className={`${calculateUSDPrice() === amount ? styles["selected"] : ""} ${styles["amount-button"]}`}
                  onClick={() => updateAmount(amount)}
                >
                  $ {amount}
                </button>
              );
            })}
          <input
            inputmode="numeric"
            type="number"
            min={0}
            onChange={handleInputChange}
            className={`${currentAmount === customAmount ? styles["selected"] : ""} ${displayCrypto ? styles["amount-full-width"] : ""} ${styles["amount-input"]}`}
            placeholder={placeholder}
            value={customAmount}
          />
          <span className={`${styles["dollar-input-denomination"]}`}>
            {!displayCrypto && "$"}
          </span>
          <span className={`${styles["amount-input-denomination"]}`}>
            {displayCrypto && displayChain}
          </span>
        </div>
        {/* amount display*/}
        <div className="col-span-12 md:col-span-5 text-right align-top">
          <h2 className={`${styles["large-currency-display"]}`}>
            {displayCrypto ? (
              <span>
                {roundCryptoPrice()}{" "}
                <span className={`${styles["currency"]} align-middle`}>
                  {displayChain}
                </span>
              </span>
            ) : (
              <span>
                ${calculateUSDPrice()}{" "}
                <span className={`${styles["currency"]} align-middle`}>
                  USD
                </span>
              </span>
            )}
          </h2>
          <div className={`${styles["small-currency-display"]}`}>
            {!displayCrypto ? (
              <span>
                {roundCryptoPrice()} {displayChain}
              </span>
            ) : (
              <span>${calculateUSDPrice()} USD</span>
            )}
          </div>
          <div
            onClick={() => handleDisplayCryptoChange()}
            className={`${styles["exchange-icon"]}`}
          ></div>
        </div>
      </div>
    </>
  );
}
