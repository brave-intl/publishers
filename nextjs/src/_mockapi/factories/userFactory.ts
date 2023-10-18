import { faker } from '@faker-js/faker';
import { Factory } from 'miragejs';

const userFactory = Factory.extend({
  get firstName() {
    return faker.person.firstName();
  },
  get lastName() {
    return faker.person.lastName();
  },
  get name() {
    return faker.person.fullName({
      firstName: this.firstName,
      lastName: this.lastName,
    });
  },
  get streetAddress() {
    return faker.location.streetAddress();
  },
  get city() {
    return faker.location.city();
  },
  get state() {
    return faker.location.state();
  },
  get zipCode() {
    return faker.location.zipCode();
  },
  get phone() {
    return faker.phone.number();
  },
  get email() {
    return faker.internet.email({
      firstName: this.firstName,
      lastName: this.lastName,
    });
  },
  get avatar() {
    return faker.internet.avatar();
  },
});

export default userFactory;
