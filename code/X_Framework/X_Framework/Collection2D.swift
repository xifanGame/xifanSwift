//
//  Collection2D.swfit
//  X_Framework
//
//  Created by 173 on 15/9/16.
//  Copyright (c) 2015年 yeah. All rights reserved.
//

import Foundation

//MARK: collection 2d type
public protocol Collection2DType
{
    //element type
    typealias Element
    
    //columns
    var columns: Int{get}
    
    //rows
    var rows: Int{get}
    
    //cuont
    var count: Int{get}
    
    //subscript
    subscript(column:Int, row:Int) -> Element {get set}
    
    //column, row is valid
    func isValid(column:Int, _ row:Int) -> Bool
}
//MARK: extension public
extension Collection2DType
{
    //column, row is valid
    public func isValid(column:Int, _ row:Int) -> Bool
    {
        return column >= 0 && column < columns && row >= 0 && row < rows;
    }
}
//MARK: extension internal
extension Collection2DType
{
    //return index in collection at column and row
    func indexAt(column:Int, _ row:Int) -> Int?
    {
        guard self.isValid(column, row) else {return nil;}
        return column + columns * row
    }
    
    //return position in collection, index: [0, count)
    func positionAt(index: Int) -> (column:Int, row:Int)?
    {
        guard index > -1 && index < self.count else{return nil;}
        let column = index % self.columns;
        let row:Int = index / self.columns;
        return (column: column, row: row);
    }
}
//MARK: extension CollectionType
extension Collection2DType where Self: CollectionType, Self.Generator.Element == Self.Element, Self.Index == Int
{
    //return element position
    @warn_unused_result
    public func positionOf(@noescape predicate: (Self.Generator.Element) throws -> Bool) rethrows ->(column:Int, row:Int)?
    {
        guard let index = try self.indexOf(predicate) else {return nil;}
        return positionAt(index);
    }
}
extension Collection2DType where Self: CollectionType, Self.Generator.Element == Self.Element, Self.Index == Int, Self.Generator.Element: Equatable
{
    //if exist, return position else return nil
    @warn_unused_result
    public func positionOf(element: Self.Element) -> (column:Int, row:Int)?
    {
        guard let index = self.indexOf(element) else {return nil;}
        return positionAt(index);
    }
}
//MARK: extension CustomStringConvertible
extension Collection2DType where Self: CustomDebugStringConvertible
{
    public var debugDescription:String{
        var text:String = "";
        for r in 0..<self.rows
        {
            for c in 0..<self.columns
            {
                text += "\(self[c, r]) ";
            }
            text += "\n";
        }
        return text;
    }
}

//MARK: struct array 2d
public struct Array2D<T>
{
    public typealias Element = T;
    
    //source
    private var source: [T];
    private(set) public var columns, rows:Int;
    
    public init(columns:Int, rows:Int, repeatValue: T, values: [T]? = nil)
    {
        self.columns = columns;
        self.rows = rows;
        let c = columns * rows
        guard let vs = values else{
            self.source = Array<T>(count: c, repeatedValue: repeatValue);
            return;
        }
        var temp = Array<T>(vs.prefix(c));
        if temp.count < c{
            temp += Array<T>(count: c - temp.count, repeatedValue: repeatValue);
        }
        self.source = temp;
    }
}
extension Array2D where T: NilLiteralConvertible
{
    public init(columns:Int, rows:Int)
    {
        self.init(columns: columns, rows: rows, repeatValue: nil);
    }
}
//MARK: extension Array2DType
extension Array2D: Collection2DType, CollectionType
{
    //subscript
    public subscript(column:Int, row:Int) -> T {
        set{
            guard let index = self.indexAt(column, row) else{return;}
            self.source[index] = newValue;
        }
        get{
            let index = self.indexAt(column, row)!;
            return self.source[index];
        }
    }
    
    /// collection
    public var startIndex: Int {return 0}
    public var endIndex: Int {return self.source.count;}
    public subscript(i: Int) -> T{return self.source[i]}
}
extension Array2D: CustomDebugStringConvertible{}