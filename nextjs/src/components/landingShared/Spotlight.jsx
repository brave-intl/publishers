'use client'

import Carousel from '../Carousel';
import styles from '@/styles/LandingPages.module.css';
import BakerCard_webp from "~/images/card-baker.webp";
import BakerCard_png from "~/images/card-baker.png";
import DefrancoCard_webp from "~/images/card-defranco.webp";
import DefrancoCard_png from "~/images/card-defranco.png";
import ScottyCard_webp from "~/images/card-scotty.webp";
import ScottyCard_png from "~/images/card-scotty.png";
import { useTranslations } from 'next-intl';

function Slide({ quote, text, link, card, alt }) {
  return (
    <div className={`${styles['box']} flex-col`}>
      <div className={`${styles['box']} ${styles['carousel-container']}`}>
        <div className={`${styles['box']} ${styles['carousel-quote']}`}>
          <h3 className={`${styles['spotlight-heading']}`}>
            {quote}
          </h3>
          <p className="text-[#808080] my-[1em] font-semibold">
            {text}
          </p>
        </div>
        <a 
          className={`${styles['box']} ${styles['carousel-img']}`}
          href={link}
        >
          <img
            src={card.webp.src}
            className="object-contain w-full h-full flex-[1_1_0%] overflow-hidden"
            alt={alt}
            onError={ (e) => e.currentTarget.src = card.default.src }
          />
        </a>
      </div>
    </div>
  );
}

export default function Spotlight() {
  const t = useTranslations();

  const slides = [
    <Slide
      card={{webp: ScottyCard_webp, default: ScottyCard_png}}
      link={t("landingPages.spotlight.scottyHref")}
      text={t("landingPages.spotlight.scottyCredit")}
      quote={t("landingPages.spotlight.scottyQuote")}
      alt={t("landingPages.spotlight.scottyAlt")}
    />,
    <Slide
      card={{webp: BakerCard_webp, default: BakerCard_png}}
      link={t("landingPages.spotlight.bakerHref")}
      text={t("landingPages.spotlight.bakerCredit")}
      quote={t("landingPages.spotlight.bakerQuote")}
      alt={t("landingPages.spotlight.bakerAlt")}
    />,
    <Slide
      card={{webp: DefrancoCard_webp,default: DefrancoCard_png}}
      link={t("landingPages.spotlight.defrancoHref")}
      text={t("landingPages.spotlight.defrancoCredit")}
      quote={t("landingPages.spotlight.defrancoQuote")}
      alt={t("landingPages.spotlight.defrancoAlt")}
    />
  ]
  
  return (
    <div className={`${styles['box']} flex-col items-center p-[48px]`}>
      <div className={`${styles['box']} items-center flex-col w-full max-w-1200`}>
        <div className={`${styles['box']} items-center flex-col p-[24px]`}>
          <h3 className={`${styles['spotlight-heading']} my-[1em]`} >
            {t("landingPages.spotlight.heading")}
          </h3>
          <p className="text-[#808080] text-center leading-[1.6em] my-[1em]">
            {t("landingPages.spotlight.subhead")}
          </p>
        </div>
        <div className={`${styles['box']} w-full flex-col`}>
          <Carousel items={slides} slideTime={9000}/>
        </div>
      </div>
    </div>
  );
};
