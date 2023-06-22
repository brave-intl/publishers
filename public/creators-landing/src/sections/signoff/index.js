import React, { useEffect, useState } from 'react'
import { Box, Heading, Image, ResponsiveContext } from 'grommet'
import { Container, PrimaryButton } from '../../components'
import CreatorsWide_webp from '../../components/img/creator-logos-wide.webp'
import CreatorsWide_png from '../../components/img/creator-logos-wide.png'
import CreatorsMobile_webp from '../../components/img/creator-logos-mobile.webp'
import CreatorsMobile_png from '../../components/img/creator-logos-mobile.png'
import locale from '../../locale/en'
import { FormattedMessage, useIntl } from 'react-intl';

export const Signoff = () => {
  const intl = useIntl();
  const [channelsCount, SetChannelsCount] = useState(1000000); // defaults to 1mil

  useEffect(() => {
    fetchTotalVerifiedChannels();
  }, []);

  const fetchTotalVerifiedChannels = async () => {
    try {
      const response = await fetch("/api/v3/public/channels/total_verified");
      const result = await response.json();

      SetChannelsCount(result);
    } catch(err) {
      console.error(err)
    }
  }

  return (
    <Box align='center'>
      <Container align='center' pad='large'>
        <Box pad={{ horizontal: 'large' }}>
          <Heading alignSelf='center' level='4' textAlign='center'>
            <FormattedMessage id="signoff.headline" values={{
              count: <strong>{intl.formatNumber(channelsCount)}</strong>
            }} />
          </Heading>
          <ResponsiveContext.Consumer>
            {size => {
              if (size >= 'medium') {
                return (
                  <Box pad='24px' id='signoff'>
                    <Image
                      src={CreatorsMobile_webp}
                      fallback={CreatorsMobile_png}
                      fit='contain'
                    />
                  </Box>
                )
              } else {
                return (
                  <Box pad={{ horizontal: 'large' }}>
                    <Image
                      src={CreatorsWide_webp}
                      fallback={CreatorsWide_png}
                      fit='contain'
                    />
                  </Box>
                )
              }
            }}
          </ResponsiveContext.Consumer>
        </Box>
        <PrimaryButton
          label={intl.formatMessage({ id: "signoff.btn" })}
          margin='large'
          href={locale.signoff.btnHref}
          name={intl.formatMessage({ id: "signoff.btn" })}
        />
      </Container>
    </Box>
  )
}
