/** @jsxImportSource react */
import {Composition} from 'remotion';
import {BanoIntro} from './BanoIntro';
import {BanoPromoTemplate} from './BanoPromoTemplate';

export const FPS = 30;
export const VIDEO_WIDTH = 1080;
export const VIDEO_HEIGHT = 1920;
export const DURATION_IN_FRAMES = 300;

export const RemotionRoot = () => {
  return (
    <>
      <Composition
        id="BanoIntro"
        component={BanoIntro}
        durationInFrames={DURATION_IN_FRAMES}
        fps={FPS}
        width={VIDEO_WIDTH}
        height={VIDEO_HEIGHT}
        defaultProps={{}}
      />
      <Composition
        id="BanoPromoTemplate"
        component={BanoPromoTemplate}
        durationInFrames={2946}
        fps={60}
        width={736}
        height={414}
        defaultProps={{}}
      />
    </>
  );
};
