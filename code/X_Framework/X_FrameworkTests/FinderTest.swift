//
//  FinderTest.swift
//  X_Framework
//
//  Created by xifanGame on 15/9/17.
//  Copyright © 2015年 yeah. All rights reserved.
//

import UIKit
@testable import X_Framework;


//typealias PF2 = BreadthBestPathFinder<FinderPoint2D>
typealias PF2 = DijkstraPathFinder<FinderPoint2D>
typealias PF = AstarFinder<FinderPoint2D>
//typealias PF = GreedyBestFinder<FinderPoint2D>


func pathFinderTest(markVisited: Bool = true, markPath: Bool = true, isDiagnal: Bool = false, multiGoals: Bool = false) {
    let size = 50;
    let mp = size - 1;
    var conf = Array2D<Int?>(columns: size, rows: size, repeatValue: 1);
    var hinder = [FinderPoint2D]();
    for i in 10...49{
        if i < 30{
            hinder.append(FinderPoint2D(x: i, y: 15))
            conf[i, 15] = .None;
        }
        hinder.append(FinderPoint2D(x: 15, y: i));
        conf[15, i] = .None;
    }
    let h2d: FinderHeuristic2D = isDiagnal ? .Chebyshev : .Manhattan;
    let m: FinderModel = isDiagnal ? .Diagonal : .Straight;
    

    var start = FinderPoint2D(x: size >> 1, y: size >> 1);
    let goals = [FinderPoint2D(x: 0, y: 0), FinderPoint2D(x: mp, y: 0), FinderPoint2D(x: 0, y: mp), FinderPoint2D(x: mp, y: mp)];
    let goal = goals[0];
    
    let source = TestFinderDataSource(conf: conf, m, h2d);
    let result: [FinderPoint2D: [FinderPoint2D]]!;
    let getVisited: (() -> [FinderElement<FinderPoint2D>])!
    if multiGoals {
        var finder = PF2(delegate: FinderDelegate<FinderPoint2D>());
        result = finder.find(from: goals, to: start, option: source);
        getVisited = {return finder.backtraceRecord();}
    }
    else{
        start = goals[3];
//        start = FinderPoint2D(x: 30, y: 17)
        var finder = PF(delegate: FinderDelegate<FinderPoint2D>());
        result = finder.find(from: start, to: goal, option: source);
        getVisited = {return finder.backtraceRecord();}
    }
    
    
    guard markPath else {return;}
    
    var printMap = Array2D(columns: size, rows: size, repeatValue: "✅");
    if markVisited{
        let visited = getVisited()
        visited.forEach{
            let point = $0.point;
            guard let parentpoint = $0.backward else {return;}
            let arrow = TestArrow.getArrow(point.x, y1: point.y, x2: parentpoint.x, y2: parentpoint.y).description;
            printMap[point.x , point.y] = arrow;
        }
    }
    
    for hinderPoint in hinder{
        printMap[hinderPoint.x, hinderPoint.y] = "❌";
    }
    
    result.forEach{
        let _ = $0
        let ps = $1;
        ps.forEach{
            let p = $0;
            let arrow = "📍";
            printMap[p.x, p.y] = arrow;
        }
    }
    printMap[start.x, start.y] = "🚹";
    
    for g in goals{
        printMap[g.x , g.y] = "🚺";
        guard multiGoals else{break;}
    }
    
    print(printMap);
}

struct TestFinderDataSource{
    let config: Array2D<Int?>;
    
    let model: FinderModel;
    
    let heuristic:FinderHeuristic2D
    
    typealias Point = FinderPoint2D;
    
    init(conf: Array2D<Int?>, _ model: FinderModel = .Straight, _ h2d: FinderHeuristic2D){
        self.config = conf;
        self.model = model;
        self.heuristic = h2d;
    }
}
extension TestFinderDataSource: FinderOption2DType{
    ///return calculate movement cost from f to t if it is validity(and exist)
    ///otherwise return nil
    func getCost(x: Int, y: Int) -> CGFloat? {
        guard x > -1 && x < self.config.columns && y > -1 && y < self.config.rows else {return .None;}
        guard let cost = self.config[x, y] else {return .None;}
        return CGFloat(cost);
    }
}