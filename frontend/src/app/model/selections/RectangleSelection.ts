import {SliceSelection} from './SliceSelection';
import {LabelTag} from '../labels/LabelTag';

export class RectangleSelection extends SliceSelection {

    // Normalized parameters of selection (<0;1>)
    _positionX: number;
    _positionY: number;
    _width: number;
    _height: number;

    constructor(x: number, y: number, depth: number, tag: LabelTag, width?: number, height?: number) {
        super();
        this._positionX = x;
        this._positionY = y;
        this._width = width ? width : 0;
        this._height = height ? height : 0;
        this.sliceIndex = depth;
        this.label_tag = tag;
        this.label_tool = 'RECTANGLE';
    }

    public get positionX() {
        return this._positionX;
    }

    public get positionY() {
        return this._positionY;
    }

    public get width() {
        return this._width;
    }

    public get height() {
        return this._height;
    }

    public updateWidth(newWidth: number): void {
        this._width = newWidth;
    }

    public updateHeight(newHeight: number): void {
        this._height = newHeight;
    }

    public toJSON() {
        let correctPositionX = this._positionX;
        let correctPositionY = this._positionY;
        let correctWidth = this._width;
        let correctHeight = this._height;

        if (this._width < 0) {
            correctPositionX += this._width;
            correctWidth = Math.abs(this._width);
        }
        if (this._height < 0) {
            correctPositionY += this._height;
            correctHeight = Math.abs(this._height);
        }
        return {
            'slice_index': this.sliceIndex,
            'x': correctPositionX,
            'y': correctPositionY,
            'width': correctWidth,
            'height': correctHeight,
            'tag': this.label_tag.key,
            'tool': this.label_tool
        };
    }
}
