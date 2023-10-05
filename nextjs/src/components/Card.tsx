import clsx from 'clsx';
import { FC } from 'react';

type Props = {
  children: React.ReactNode;
  width?: number;
  className?: string;
  inner?: boolean;
  border?: boolean;
};

const Card: FC<Props> = ({ border, children, width, className, inner }) => {
  return (
    <div
      className={clsx(
        'shadow bg-white',
        {
          'px-4 pb-5 pt-4': !inner,
          'p-2': inner,
          'border-primary': border,
        },
        'rounded',
        className,
      )}
      style={{ width: `${width}px` }}
    >
      {children}
    </div>
  );
};

export default Card;
