import React from "react";
import { Button, Opacity, Text, Dialogue } from "../style.jsx";

class FailureDialog extends React.PureComponent {
  render() {
    return (
      <div>
        <Opacity />
        <Dialogue id="save-container" save>
          {this.props.saving === false && (
            <div>
              <Text dialogueHeader>{this.props.message}</Text>
              <Text dialogueSubtext>
                An error occurred while processing your image.
                <br /> <br />
                Please try resizing your image or converting it into a different
                image format.
              </Text>
              <Button dialoguePrimary onClick={this.props.setEditMode}>
                OK
              </Button>
            </div>
          )}
        </Dialogue>
      </div>
    );
  }
}

export default FailureDialog;
