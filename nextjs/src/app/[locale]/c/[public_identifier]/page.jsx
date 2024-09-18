'use client';

import { useParams } from 'next/navigation';
import PublicChannelPage from "./PublicChannelPage";

export default function PublicChannelPageContainer() {
  const params = useParams();
  const publicIdentifier = params['public_identifier'];

  return (
    <div>
      <PublicChannelPage publicIdentifier={publicIdentifier} previewMode={false} />
    </div>
  );
}
