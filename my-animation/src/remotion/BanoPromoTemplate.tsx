/** @jsxImportSource react */
import React from 'react';
import {
  AbsoluteFill,
  Audio,
  Img,
  interpolate,
  staticFile,
  useCurrentFrame,
} from 'remotion';
import './BanoPromoTemplate.css';

const clamp = {
  extrapolateLeft: 'clamp' as const,
  extrapolateRight: 'clamp' as const,
};

const assets = [
  'purple-gold-marble-reference.png',
  'game-bg-marble.webp',
  'game-bg-city.png',
  'game-bg-terrain.jpg',
  'game-bg-hero.webp',
  'purple-gold-marble-reference.png',
];

const palette = ['#7cff15', '#ff155f', '#ffc421', '#b737ff', '#22d8ff'];

const phaseColor = (frame: number) => palette[Math.floor(frame / 720) % palette.length];

const progress = (frame: number, start: number, end: number) =>
  interpolate(frame, [start, end], [0, 1], clamp);

const Flash = ({frame}: {frame: number}) => {
  const pulse = Math.max(
    progress(frame % 240, 0, 10) * (1 - progress(frame % 240, 10, 42)),
    progress((frame + 80) % 360, 0, 12) * (1 - progress((frame + 80) % 360, 12, 48)),
  );

  return <div className="promo-flash" style={{opacity: pulse * 0.42}} />;
};

const GrungeText = ({frame}: {frame: number}) => {
  const color = phaseColor(frame);
  const slide = interpolate(frame % 360, [0, 360], [-80, 36]);

  return (
    <div className="grunge-text" style={{color, transform: `translateX(${slide}px)`}}>
      <div>ACTION</div>
      <div>MARBLE</div>
      <div>BATTLE</div>
    </div>
  );
};

const Panel = ({
  frame,
  index,
  asset,
  className,
}: {
  frame: number;
  index: number;
  asset: string;
  className: string;
}) => {
  const local = (frame + index * 37) % 360;
  const zoom = interpolate(local, [0, 360], [1.08, 1.26]);
  const x = interpolate(local, [0, 360], [-18 + index * 3, 12 - index * 2]);
  const grayscale = index % 2 === 0 ? 0.95 : 0.35;
  const color = phaseColor(frame + index * 80);

  return (
    <div className={`promo-panel ${className}`} style={{borderColor: color}}>
      <Img
        className="promo-panel-img"
        src={staticFile(asset)}
        style={{
          filter: `grayscale(${grayscale}) contrast(1.25) brightness(0.82) saturate(1.18)`,
          transform: `translate(${x}px, 0) scale(${zoom})`,
        }}
      />
      <div className="promo-panel-tint" style={{backgroundColor: color}} />
    </div>
  );
};

const Montage = ({frame}: {frame: number}) => {
  const color = phaseColor(frame);
  const shake = Math.sin(frame * 0.72) * 1.4;
  const panelSet = Math.floor(frame / 360) % assets.length;

  return (
    <AbsoluteFill className="montage" style={{transform: `translate(${shake}px, ${-shake * 0.4}px)`}}>
      <GrungeText frame={frame} />
      <Panel frame={frame} index={0} asset={assets[panelSet % assets.length]} className="panel-a" />
      <Panel frame={frame} index={1} asset={assets[(panelSet + 1) % assets.length]} className="panel-b" />
      <Panel frame={frame} index={2} asset={assets[(panelSet + 2) % assets.length]} className="panel-c" />
      <Panel frame={frame} index={3} asset={assets[(panelSet + 3) % assets.length]} className="panel-d" />
      <div className="scanline" />
      <div className="promo-corner corner-left" style={{borderColor: color}} />
      <div className="promo-corner corner-right" style={{borderColor: color}} />
    </AbsoluteFill>
  );
};

const PlayCard = ({frame}: {frame: number}) => {
  const local = frame % 720;
  const color = phaseColor(frame);
  const inOut = progress(local, 35, 90) * (1 - progress(local, 260, 340));
  const scale = 0.85 + inOut * 0.15 + Math.sin(frame * 0.12) * 0.012;

  return (
    <div className="play-card" style={{opacity: inOut, transform: `translate(-50%, -50%) scale(${scale})`}}>
      <div className="play-word" style={{color}}>PLAY</div>
      <div className="box-word">BANO</div>
    </div>
  );
};

const LogoReveal = ({frame}: {frame: number}) => {
  const beat = frame % 720;
  const logoIn = progress(beat, 130, 190) * (1 - progress(beat, 560, 700));
  const color = phaseColor(frame);
  const ring = 0.84 + Math.sin(frame * 0.08) * 0.04;

  return (
    <div className="logo-reveal" style={{opacity: logoIn}}>
      <div className="energy-ring" style={{borderColor: color, transform: `translate(-50%, -50%) scale(${ring})`}} />
      <Img className="promo-logo" src={staticFile('bano-ke-logo-transparent.png')} />
      <div className="logo-sparks" style={{backgroundColor: color}} />
    </div>
  );
};

const ColorDemo = ({frame}: {frame: number}) => {
  const local = frame - 720;
  const show = progress(local, 0, 80) * (1 - progress(local, 520, 690));
  const color = phaseColor(frame);

  return (
    <div className="color-demo" style={{opacity: show}}>
      <div className="color-caption">YOU CAN CHANGE COLOUR EASILY</div>
      <div className="mini-preview">
        <Img src={staticFile('purple-gold-marble-reference.png')} />
        <div className="mini-swatch" style={{background: color}} />
      </div>
    </div>
  );
};

const FinalLogo = ({frame}: {frame: number}) => {
  const show = progress(frame, 2380, 2500);
  const fade = 1 - progress(frame, 2860, 2946);
  const color = phaseColor(frame);
  const scale = 0.9 + show * 0.12 + Math.sin(frame * 0.08) * 0.015;

  return (
    <AbsoluteFill className="final-promo" style={{opacity: show * fade}}>
      <div className="final-orb" style={{borderColor: color}} />
      <Img
        className="final-logo-img"
        src={staticFile('bano-ke-logo-transparent.png')}
        style={{transform: `translate(-50%, -50%) scale(${scale})`}}
      />
      <div className="final-subtitle">MARBLE BATTLE ARENA</div>
    </AbsoluteFill>
  );
};

export const BanoPromoTemplate: React.FC = () => {
  const frame = useCurrentFrame();
  const color = phaseColor(frame);
  const bg = assets[Math.floor(frame / 480) % assets.length];
  const bgZoom = interpolate(frame % 480, [0, 480], [1.08, 1.2]);

  return (
    <AbsoluteFill className="bano-promo-template">
      <Audio src={staticFile('reference-audio.m4a')} />
      <Img className="promo-bg" src={staticFile(bg)} style={{transform: `scale(${bgZoom})`}} />
      <div className="promo-darken" />
      <div className="neon-wash" style={{backgroundColor: color}} />
      <Montage frame={frame} />
      <PlayCard frame={frame} />
      <LogoReveal frame={frame} />
      <ColorDemo frame={frame} />
      <FinalLogo frame={frame} />
      <Flash frame={frame} />
    </AbsoluteFill>
  );
};
