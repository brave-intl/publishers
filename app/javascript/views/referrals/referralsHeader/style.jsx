import styled, { css } from 'styled-components';

export const StyledWrapper = styled.div
`
  border-radius: 6px;
  background-color: white;
  box-shadow: rgba(99, 105, 110, 0.18) 0px 1px 12px 0px;
  padding: 30px;

  ${props => props.title &&
    `
        font-weight: bold;
        font-size: 22px;
    `
  }
`;

export const StyledContentWrapper = styled.div
`
  display: flex;
`;
