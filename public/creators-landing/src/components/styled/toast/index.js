import React from "react";
import { Box, Layer, Text, Button } from "grommet";
import { NotificationWrapper, CloseIcon, IconContainer } from "../../index";

export function Toast(props) {
  return (
    <Layer
      position={props.display}
      modal={false}
      margin={{ vertical: "xlarge", horizontal: "none" }}
      responsive={false}
      className="notification-layer"
      plain>
      <NotificationWrapper
        align="center"
        direction="row"
        gap="small"
        justify="between"
        round="medium"
        elevation="medium"
        pad={{ vertical: "small", horizontal: "medium" }}
        background="#F3F3FD">
        <Box align="center" direction="row" gap="small">
          <IconContainer
            minWidth="32px"
            height="32px"
            width="32px"
            color="#339AF0"
          />
          <Text>{props.text}</Text>
          <Button icon={<CloseIcon />} onClick={() => {}} plain />
        </Box>
      </NotificationWrapper>
    </Layer>
  );
}
