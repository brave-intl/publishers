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
        'shadow bg-container rounded px-2 md:px-4 pb-5 pt-4 transition-colors',
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
