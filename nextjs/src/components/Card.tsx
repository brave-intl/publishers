import clsx from 'clsx';
import { FC } from 'react';

type Props = {
  children: React.ReactNode;
  width?: number;
  className?: string;
  id?: string; // make id optional
};

const Card: FC<Props> = ({ children, width, className, id }) => {
  return (
    <div
      className={clsx(
        'shadow rounded bg-container px-2 pb-5 pt-4 transition-colors md:px-4',
        className,
      )}
      style={{ width: `${width}px` }}
      id={id ? `channel_row_${id}` : ''}
    >
      {children}
    </div>
  );
};

export default Card;
