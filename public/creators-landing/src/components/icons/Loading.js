import React from "react";

export const Loading = () => (
  <svg
    xmlns="http://www.w3.org/2000/svg"
    x="0px"
    y="0px"
    width="26px"
    height="20.5px"
    fill="white"
    viewBox="0 0 32 32"
  >
    <path d="M6.5 23.5c-.7 0-1.4-.4-1.7-1C3.6 20.5 3 18.3 3 16 3 8.8 8.8 3 16 3s13 5.8 13 13c0 1.1-.9 2-2 2s-2-.9-2-2c0-5-4-9-9-9s-9 4-9 9c0 1.6.4 3.1 1.2 4.5.6 1 .2 2.2-.7 2.7-.4.2-.7.3-1 .3z">
      <animateTransform
        attributeType="xml"
        attributeName="transform"
        type="rotate"
        from="0 16 16"
        to="360 16 16"
        dur=".5s"
        repeatCount="indefinite"
      />
    </path>
  </svg>
);
