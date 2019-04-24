import React from "react";
import { Layer, Text, Button } from "grommet";
import { NotificationWrapper, CloseIcon, IconContainer } from "../../index";
import { InfoIcon } from "../../index";

export function Toast(props) {
  return (
    <Layer
      position={props.notification.show ? "bottom" : "hidden"}
      modal={false}
      margin={{ vertical: "xlarge", horizontal: "none" }}
      responsive={false}
      className="notification-layer"
      plain
    >
      <NotificationWrapper
        align="center"
        direction="row"
        gap="small"
        justify="between"
        round="medium"
        elevation="medium"
        pad={{ vertical: "small", horizontal: "medium" }}
        background="#F3F3FD"
      >
        <IconContainer
          minWidth="24px"
          height="24px"
          width="24px"
          color="#E32444"
        >
          <InfoIcon />
        </IconContainer>
        <Text size="16px">{props.notification.text}</Text>
        <Button icon={<CloseIcon />} onClick={props.closeNotification} plain />
      </NotificationWrapper>
    </Layer>
  );
}
