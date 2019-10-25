import * as React from "react";
import * as ReactDOM from "react-dom";
import { FormattedMessage, IntlProvider } from "react-intl";
import { submitForm } from "../utils/request";

import { LoaderIcon } from "brave-ui/components/icons";
import en, { flattenMessages } from "../locale/en";
import routes from "../views/routes";

interface IContactFormState {
  isEditMode: boolean;
  name: string;
  pendingEmail: string;
}

// This react component is used on the promo panel for the homepage.
// This displays a listing of group, price, and confirmed count to the end user

class ContactForm extends React.Component<any, IContactFormState> {
  constructor(props) {
    super(props);

    this.state = {
      isEditMode: false,
      name: this.props.name,
      pendingEmail: this.props.pending_email
    };
  }

  public setEdit = () => {
    this.setState({ isEditMode: true });
  };

  public cancelEdit = () => {
    this.setState({ isEditMode: false });
  };

  public save = (name, email) => {
    let pendingEmail = this.state.pendingEmail;
    if (email !== this.props.email) {
      pendingEmail = email;
    }
    this.setState({ name, pendingEmail, isEditMode: false });
  };

  public render() {
    return (
      <React.Fragment>
        <div className="d-flex justify-content-between">
          <h5>
            <FormattedMessage id="settings.contact.heading" />
          </h5>
          <a href="#" onClick={this.setEdit}>
            <FormattedMessage id="settings.contact.edit" />
          </a>
        </div>

        {this.state.isEditMode && (
          <EditForm
            {...this.props}
            cancelEdit={this.cancelEdit}
            save={this.save}
          />
        )}

        {!this.state.isEditMode && (
          <div>
            <div>{this.state.name}</div>
            <div>{this.props.email}</div>

            {this.state.pendingEmail && (
              <div className="alert alert-warning mt-2">
                <FormattedMessage
                  id="settings.contact.pendingEmail"
                  values={{
                    email: this.state.pendingEmail
                  }}
                />
              </div>
            )}
          </div>
        )}
      </React.Fragment>
    );
  }
}

const EditForm = props => {
  const [name, setName] = React.useState(props.name);
  const [email, setEmail] = React.useState(props.pending_email || props.email);
  const [error, setError] = React.useState(null);
  const [isLoading, setLoading] = React.useState(false);

  const submit = async event => {
    setLoading(true);
    event.preventDefault();

    const data = new FormData();
    data.append("publisher[name]", name);
    data.append("publisher[pending_email]", email);
    data.append("_method", "patch");

    await fetch(routes.publishers.update.path, {
      body: data,
      headers: {
        Accept: "application/json",
        "X-CSRF-Token": document.head
          .querySelector("[name=csrf-token]")
          .getAttribute("content"),
        "X-Requested-With": "XMLHttpRequest"
      },
      method: "POST"
    }).then(response => {
      setLoading(false);

      if (response.status === 400) {
        setError(<FormattedMessage id="settings.contact.error" />);
        return;
      }

      response
        .json()
        .then(json => {
          props.save(name, email);
        })
        .catch(e => {
          setError(e);
        });
    });
  };

  return (
    <form className="in-place-edit" onSubmit={submit} id="update_contact">
      <div className="form-group">
        <label>
          <FormattedMessage id="settings.contact.name" />
        </label>
        <input
          value={name}
          onChange={e => setName(e.target.value)}
          className="form-control"
        />
      </div>
      <div className="form-group">
        <label>
          <FormattedMessage id="settings.contact.email" />
        </label>
        <input
          value={email}
          onChange={e => setEmail(e.target.value)}
          className="form-control"
        />
      </div>
      <div className="button form-group">
        <input type="submit" className="btn btn-primary" />
        <a href="#" onClick={props.cancelEdit} className="btn btn-link">
          <FormattedMessage id="cancel" />
        </a>
        {isLoading && <LoaderIcon style={{ width: "48px" }} />}
      </div>
      {error && <div className="mt-4 alert alert-warning">{error}</div>}
    </form>
  );
};

document.addEventListener("DOMContentLoaded", () => {
  const element = document.getElementById("contact_section");
  const props = JSON.parse(element.dataset.props);
  ReactDOM.render(
    <IntlProvider
      locale={document.body.dataset.locale}
      messages={flattenMessages(en)}
    >
      <ContactForm {...props} />
    </IntlProvider>,
    element
  );

  const publisherVisibleCheckbox = document.getElementById("publisher_visible");
  publisherVisibleCheckbox.addEventListener(
    "click",
    event => {
      submitForm("update_publisher_visible_form", "PATCH", true);
    },
    false
  );
});
